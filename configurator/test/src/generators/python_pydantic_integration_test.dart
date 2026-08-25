import 'dart:io';

import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

import 'generator_fixture.dart';

void main() {
  test('generated Python imports without Pydantic and snapshots when available',
      () async {
    const generator = PythonConfigGenerator();
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'configurator-python-pydantic-',
    );
    addTearDown(() => temporaryDirectory.delete(recursive: true));

    final generatedFile = File(
      '${temporaryDirectory.path}/app_scope_config.py',
    );
    await generatedFile.writeAsString(
      generator.generate(
        name: 'app_scope',
        configuration: generatorFixture(),
      ),
    );

    final runtimeSource = Directory('../configurator_python/src').absolute.path;
    final pythonExecutable =
        Platform.environment['CONFIGURATOR_TEST_PYTHON'] ?? 'python3';
    final result = await Process.run(
      pythonExecutable,
      [
        '-B',
        '-c',
        _pythonIntegrationScript,
        generatedFile.path,
        runtimeSource,
      ],
    );

    expect(
      result.exitCode,
      0,
      reason: 'stdout:\n${result.stdout}\nstderr:\n${result.stderr}',
    );
  });
}

const _pythonIntegrationScript = r'''
import importlib.util
import sys

generated_path, runtime_source = sys.argv[1:]
sys.path.insert(0, runtime_source)

spec = importlib.util.spec_from_file_location("app_scope_config", generated_path)
assert spec is not None and spec.loader is not None
generated = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = generated
spec.loader.exec_module(generated)

from configurator import ConfigScope, Configuration
from configurator.pydantic_support import (
    PYDANTIC_AVAILABLE,
    PydanticUnavailableError,
)

override = ConfigScope(
    name="server-override",
    weight=100,
    flags={"featureEnabled": False},
    misc={"retryCount": 9},
)
config = generated.AppScopeConfig(
    Configuration([generated.GENERATED_APP_SCOPE, override])
)

# The ordinary typed accessors never require Pydantic.
assert config.flags.feature_enabled is False
assert config.misc.retry_count == 9

try:
    snapshot = config.snapshot()
except PydanticUnavailableError:
    assert not PYDANTIC_AVAILABLE
else:
    assert PYDANTIC_AVAILABLE
    assert snapshot.flags.feature_enabled is False
    assert snapshot.misc.retry_count == 9
    assert config.to_model() == snapshot
    assert snapshot.model_config["frozen"] is True

    # This is the same dependency/response-model shape used by FastAPI. Run a
    # real request too when the optional test dependencies are installed.
    if importlib.util.find_spec("fastapi") is not None:
        from fastapi import Depends, FastAPI
        from fastapi.testclient import TestClient

        app = FastAPI()

        def get_config() -> generated.AppScopeConfig:
            return config

        @app.get("/internal/config", response_model=generated.AppScopeConfigModel)
        def read_config(
            current: generated.AppScopeConfig = Depends(get_config),
        ) -> generated.AppScopeConfigModel:
            return current.snapshot()

        response = TestClient(app).get("/internal/config")
        assert response.status_code == 200
        assert response.json()["flags"]["feature_enabled"] is False
        assert response.json()["misc"]["retry_count"] == 9
''';

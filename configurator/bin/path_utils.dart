
/// Operations on paths
class PathUtils {
  /// converts /some/path/file.json to file.json
  static String getFileName(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }

  /// converts /some/path/file.json to file
  static String getFileNameNoExtension(String path) {
    return getFileName(path).split('.').first;
  }

  /// converts /some/path/file.i18n.json to i18n.json
  static String getFileExtension(String path) {
    final fileName = getFileName(path);
    final firstDot = fileName.indexOf('.');
    return fileName.substring(firstDot + 1);
  }

  /// converts /a/b/file.json to b
  static String? getParentDirectory(String path) {
    final segments = path.replaceAll('\\', '/').split('/');
    if (segments.length == 1) {
      return null;
    }
    return segments[segments.length - 2];
  }

  /// converts /some/path/file.json to /some/path/newFile.json
  static String replaceFileName({
    required String path,
    required String newFileName,
    required String pathSeparator,
  }) {
    final index = path.lastIndexOf(pathSeparator);
    if (index == -1) {
      return newFileName;
    } else {
      return path.substring(0, index + pathSeparator.length) + newFileName;
    }
  }
}

import 'dart:io';

import 'package:path/path.dart' as p;

class StaticResUtil {
  static late String staticResPath;
  static const String urlPrefix = 'static';

  static Future<String> init(String path) async {
    staticResPath = p.join(path, 'static');
    var directory = Directory(staticResPath);
    if (!await directory.exists()) {
      await directory.create();
    }
    return staticResPath;
  }

  static Future<File> loadFile(String fileName) async {
    return File(p.join(staticResPath, fileName));
  }

  static String getStaticResAbsPath(String fileName) {
    return p.join(urlPrefix, fileName);
  }
}

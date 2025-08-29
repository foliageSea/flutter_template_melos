import 'package:app/app/common/global.dart';
import 'package:app/db/services/services.dart';
import 'package:core/core.dart';
import 'package:app/objectbox.g.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

export '../app/common/global.dart' show Global;
export 'services/services.dart';

/// 文档地址
/// https://docs.objectbox.io/
@Singleton(order: -1)
class AppDatabase with AppLogMixin {
  late final Store store;

  late String path;
  late GetIt getIt;

  Future init() async {
    final dir = await getApplicationSupportDirectory();
    path = p.join(dir.path, "db");
    logger.log("数据库 $path");
    store = await openStore(directory: path);

    await Global.getIt<UserService>().initDefaultUser();
  }

  String getPath() {
    return path;
  }
}

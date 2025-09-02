import 'package:core/core.dart' show AppLogger;
import 'package:server/src/controllers/rest_controller.dart';
import 'package:server/src/pojo/vo/log_data_vo.dart';
import 'package:server/src/result/result.dart';
import 'package:shelf_plus/shelf_plus.dart';

part 'log_controller.g.dart';

class LogController implements RestController {
  @Route.get('/list')
  Future<Response> list(Request request) async {
    var history = AppLogger().talker.history;

    var list = history
        .map(
          (e) => LogDataVo(
            message: e.message,
            logLevel: e.logLevel?.name,
            exception: e.exception.toString(),
            error: e.error.toString(),
            stackTrace: e.stackTrace.toString(),
            title: e.title,
            time: e.time.toIso8601String(),
          ).toMap(),
        )
        .toList();

    return Result.ok(list);
  }

  @override
  String getController() {
    return '/log';
  }

  @override
  Router getRouter() {
    return _$LogControllerRouter(this);
  }
}

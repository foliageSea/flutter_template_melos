import 'dart:io';

import 'package:server/src/controllers/user_controller.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_plus/shelf_plus.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'controllers/rest_controller.dart';
import 'middlewares/asset_static_handler.dart';
import 'middlewares/auth_middleware.dart';
import 'middlewares/errors_handler.dart';
import 'package:core/core.dart';

import 'utils/static_res_util.dart';

class Server {
  static const _defaultPort = 8080;
  static const _defaultHost = '0.0.0.0';

  Server._();

  static bool get isRunning => server != null;

  static HttpServer? server;

  static final List<RestController Function()> controllers = [
    () => UserController(),
  ];

  static Future<void> start({
    String host = _defaultHost,
    int port = _defaultPort,
    String? webPath,
    String? staticPath,
  }) async {
    if (server != null) {
      AppLogger().info('HTTP服务器已经在运行中');
      return;
    }

    final app = Router().plus;

    var apiHandler = _createApiHandler();
    app.mount('/api', apiHandler);

    if (staticPath != null) {
      var path = await StaticResUtil.init(staticPath);
      var staticHandler = _createStaticHandler(path);
      app.mount('/static', staticHandler);
    }

    if (webPath != null) {
      var staticHandler = createAssetStaticHandler(
        assetPath: webPath,
        urlPrefix: '/',
      );
      app.mount('/', staticHandler);
    }

    server = await io.serve(app.call, host, port);
    // ignore: avoid_print
    AppLogger().info(
      'HTTP服务器启动在 http://${server!.address.host}:${server!.port}',
    );
  }

  static Future<void> stop() async {
    // ignore: avoid_print
    if (server != null) {
      await server!.close();
      server = null;
    }
    AppLogger().warning('HTTP服务器已停止');
  }

  static String? get serverUrl {
    return 'http://$_defaultHost:$_defaultPort';
  }

  static Handler _createApiHandler() {
    final router = Router().plus;
    // 注册API路由

    for (var controller in controllers) {
      var instance = controller();
      router.mount(instance.getController(), instance.getRouter().call);
    }

    // 配置中间件
    Handler handler = const Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(logRequests())
        .addMiddleware(errorsHandler())
        .addMiddleware(AuthMiddleware.create())
        .addHandler(router.call);

    return handler;
  }

  static Handler _createStaticHandler(String webPath) {
    var staticHandler = createStaticHandler(
      webPath,
      listDirectories: true,
      useHeaderBytesForContentType: true,
    );
    var handler = const Pipeline().addHandler(staticHandler);
    return handler;
  }
}

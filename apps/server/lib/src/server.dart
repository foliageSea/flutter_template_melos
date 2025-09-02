import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:restaurant_local_server/restaurant_local_server.dart';
import 'package:server/src/controllers/log_controller.dart';
import 'package:server/src/controllers/user_controller.dart';
import 'package:server/src/pojo/vo/log_data_vo.dart';
import 'package:server/src/utils/jwt_util.dart';
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

  static const _defaultWebSocketPort = 8081;

  Server._();

  static bool get isRunning => server != null;

  static HttpServer? server;

  static WebSocketServer? webSocketServer;

  static final List<RestController Function()> controllers = [
    () => UserController(),
    () => LogController(),
  ];

  static Future<void> start({
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

    server = await io.serve(app.call, InternetAddress.anyIPv4, port);
    // ignore: avoid_print
    AppLogger().info(
      'HTTP服务器启动在 http://${InternetAddress.anyIPv4.host}:${server!.port}',
    );

    _startWebSocket();
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
    return 'http://${InternetAddress.anyIPv4.host}:$_defaultPort';
  }

  static Handler _createApiHandler() {
    final router = Router().plus;
    // 注册API路由

    for (var controller in controllers) {
      var instance = controller();
      router.mount(instance.getController(), instance.getRouter().call);
    }

    // logger(String message, bool isError) {
    //   AppLogger().info(message);
    // }

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

  static Future _startWebSocket() async {
    var eventHandlers = WebSocketServerEventHandlers(
      onClientConnect: _handleWebSocketConnect,
    );

    webSocketServer = WebSocketServer(
      config: WebSocketServerConfig(port: _defaultWebSocketPort),
      eventHandlers: eventHandlers,
    );
    await webSocketServer!.start();

    AppLogger().talker.stream.listen((e) {
      webSocketServer?.broadcastCustomMessage(
        customType: 'logger',
        customData: LogDataVo(
          message: e.message,
          logLevel: e.logLevel?.name,
          exception: e.exception?.toString(),
          error: e.error?.toString(),
          stackTrace: e.stackTrace?.toString(),
          title: e.title,
          time: e.time.toIso8601String(),
        ).toMap(),
      );
    });
  }

  static Future _handleWebSocketConnect(
    String clientId,
    ClientInfo clientInfo,
  ) async {
    var token = clientInfo.uri.queryParameters['token'];
    if (token == null) {
      await webSocketServer!.disconnectClient(clientId, 'token is null');
      return;
    }

    try {
      JwtUtil.verifyToken(token);
    } on JWTExpiredException {
      await webSocketServer!.disconnectClient(clientId, 'token is expired');
    } on JWTException {
      await webSocketServer!.disconnectClient(clientId, 'token is invalid');
    }
  }
}

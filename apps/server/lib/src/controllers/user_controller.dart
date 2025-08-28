import 'package:server/src/exceptions/business_exception.dart';
import 'package:server/src/pojo/dto/login_form_dto.dart';
import 'package:server/src/result/result.dart';
import 'package:server/src/utils/context_util.dart';
import 'package:server/src/utils/jwt_util.dart';
import 'package:server/src/utils/multipart_util.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'rest_controller.dart';

part 'user_controller.g.dart';

class UserController implements RestController {
  @Route.post('/login')
  Future<Response> login(Request request) async {
    final json = await request.body.asJson;

    var formDto = LoginFormDtoMapper.fromMap(json);
    if (formDto.username.isEmpty || formDto.password.isEmpty) {
      throw BusinessException.badRequest('请输入用户名或密码');
    }

    final token = JwtUtil.generateToken({'username': formDto.username});

    return Result.ok({'token': token});
  }

  @Route.post('/upload')
  Future<Response> upload(Request request) async {
    var result = await MultipartUtil.loadMultipart(request);
    print(result);
    var username = ContextUtil.getJwtPayloadString(request, 'username');
    return Result.ok('$username');
  }

  @override
  Router getRouter() {
    return _$UserControllerRouter(this);
  }

  @override
  String getController() {
    return '/user';
  }
}

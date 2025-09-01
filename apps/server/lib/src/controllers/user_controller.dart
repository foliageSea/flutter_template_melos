import 'package:app/app/common/global.dart';
import 'package:app/db/database.dart';
import 'package:server/src/exceptions/business_exception.dart';
import 'package:server/src/pojo/dto/login_form_dto.dart';
import 'package:server/src/result/result.dart';
import 'package:server/src/utils/context_util.dart';
import 'package:server/src/utils/jwt_util.dart';
import 'package:server/src/utils/multipart_util.dart';
import 'package:server/src/utils/static_res_util.dart';
import 'package:shelf_plus/shelf_plus.dart';

import '../pojo/vo/user_info_vo.dart';
import '../utils/validator_util.dart';
import 'rest_controller.dart';

part 'user_controller.g.dart';

class UserController implements RestController {
  @Route.post('/login')
  Future<Response> login(Request request) async {
    final json = await request.body.asJson;

    var formDto = LoginFormDtoMapper.fromMap(json);

    ValidatorUtil.validateAll([
      () => ValidatorUtil.required(formDto.username, '用户名'),
      () => ValidatorUtil.required(formDto.password, '密码'),
      () => ValidatorUtil.length(formDto.username, '用户名', min: 3, max: 20),
      () => ValidatorUtil.length(formDto.password, '密码', min: 3, max: 20),
    ]);

    UserService userService = Global.getIt();
    var user = await userService.login(formDto.username, formDto.password);

    var payload = {
      'userId': user!.id,
      'username': user.username,
      'name': user.name,
      'isAdmin': user.isAdmin,
    };

    final token = JwtUtil.generateToken(payload);

    return Result.ok({'token': token});
  }

  @Route.post('/upload')
  Future<Response> upload(Request request) async {
    var result = await MultipartUtil.loadMultipart(request);
    print(result);
    // var username = ContextUtil.getJwtPayloadString(request, 'username');

    var files = result['files'] as List<FormDataFile>;

    var list = await MultipartUtil.saveMultipleToDisk(
      files,
      StaticResUtil.staticResPath,
    );

    return Result.ok(list);
  }

  @Route.get('/info')
  Future<Response> getUserInfo(Request request) async {
    var userId = ContextUtil.getJwtPayloadInt(request, 'userId');
    if (userId == null) {
      throw BusinessException.badRequest('用户不存在');
    }
    UserService userService = Global.getIt();
    var user = await userService.getUserInfo(userId);
    if (user == null) {
      throw BusinessException.badRequest('用户不存在');
    }

    var userInfo = UserInfoVO(
      user.id,
      user.username,
      user.name,
      user.isAdmin,
      user.avatar,
    );

    return Result.ok(userInfo.toMap());
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

import 'package:app/db/dao/user_dao.dart';
import 'package:injectable/injectable.dart';

import '../database.dart';
import '../entity/user.dart';

part 'impl/user_service_impl.dart';

abstract class UserService {
  Future add(User user);
  Future<List<User>> list();
}

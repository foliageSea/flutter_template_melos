import 'package:app/db/dao/base_dao.dart';
import 'package:app/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

import '../entity/user.dart';

class UserDao extends BaseDao {
  late Box<User> userBox;

  UserDao(super.db) {
    userBox = db.box<User>();
  }

  Future add(User user) async {
    await userBox.putAsync(user);
  }

  Future<List<User>> list() async {
    return await userBox.getAllAsync();
  }

  Future<User?> getByUsername(String username) async {
    return userBox.query(User_.username.equals(username)).build().findFirst();
  }

  Future<User?> getById(int id) async {
    return userBox.get(id);
  }
}

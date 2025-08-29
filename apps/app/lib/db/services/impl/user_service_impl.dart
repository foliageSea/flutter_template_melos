part of '../user_service.dart';

@LazySingleton(as: UserService)
class UserServiceImpl implements UserService {
  late UserDao userDao;

  UserServiceImpl(AppDatabase db) {
    userDao = UserDao(db.store);
  }

  @override
  Future add(User user) {
    return userDao.add(user);
  }

  @override
  Future<List<User>> list() {
    return userDao.list();
  }

  @override
  Future<User?> login(String username, String password) async {
    var user = await userDao.getByUsername(username);
    if (user == null) {
      throw BusinessException.badRequest('用户不存在');
    }
    if (user.password != password) {
      throw BusinessException.badRequest('密码错误');
    }
    return user;
  }

  @override
  Future initDefaultUser() async {
    var user = await userDao.getByUsername('admin');
    if (user == null) {
      var defaultUser = User()
        ..username = 'admin'
        ..password = 'admin'
        ..name = '管理员'
        ..isAdmin = true
        ..createTime = DateTime.now()
        ..updateTime = DateTime.now();
      await userDao.add(defaultUser);
    }
  }

  @override
  Future<User?> getUserInfo(int userId) {
    return userDao.getById(userId);
  }
}

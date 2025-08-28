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
}

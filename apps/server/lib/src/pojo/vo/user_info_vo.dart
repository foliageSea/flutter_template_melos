import 'package:dart_mappable/dart_mappable.dart';

part 'user_info_vo.mapper.dart';

@MappableClass()
class UserInfoVO with UserInfoVOMappable {
  int id;
  String username;
  String name;
  bool isAdmin;
  String? avatar;

  UserInfoVO(this.id, this.username, this.name, this.isAdmin, this.avatar);
}

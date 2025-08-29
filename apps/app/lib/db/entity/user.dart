import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id()
  int id = 0;
  @Unique()
  late String username;
  late String password;
  late String name;
  String? avatar;
  bool isAdmin = false;
  late DateTime createTime;
  late DateTime updateTime;
}

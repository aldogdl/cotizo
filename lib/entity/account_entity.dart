import 'package:hive/hive.dart';

import '../vars/enums.dart';
part 'account_entity.g.dart';

@HiveType(typeId: accountHT)
class AccountEntity extends HiveObject {

  // flutter packages pub run build_runner build

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  String name = '';

  @HiveField(2)
  String curc = '';

  @HiveField(3)
  String password = '';

  @HiveField(4)
  String serverToken = '';

  @HiveField(5)
  String msgToken = '';

  @HiveField(6)
  List<String> roles = [];

  ///
  void fromServer(Map<String, dynamic> user) {

    id = user['id'];
    name = user['name'];
    curc = user['curc'];
    password = user['password'];
    serverToken = user['serverToken'];
    msgToken = user['msgToken'];
    roles = user['roles'];
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'name': name,
      'curc': curc,
      'password': password,
      'serverToken': serverToken,
      'msgToken': msgToken,
      'roles': roles,
    };
  }

}

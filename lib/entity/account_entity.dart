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

  ///
  Map<String, dynamic> canSolicitar() {

    final miRole = _roles(roles.first);
    if(miRole.isNotEmpty) {
      if(roles.first == 'ROLE_COTZ') {
        return {'role': roles.first, 'isCot': 0};
      }
      // final isC = roles.where((r) => r.contains('ROLE_COTZ'));
    }else{
      if(roles.first == 'ROLE_SOLZ') {
        return {'role': roles.first, 'isCot': 0};
      }
    }
    return {};
  }

  ///
  List<String> _roles(String rol) {

    final rs = <String, List<String>>{
      'ROLE_SOLZ' : [],
      'ROLE_COTZ' : ['ROLE_SOLZ'],
      'ROLE_AVO'  : ['ROLE_COTZ', 'ROLE_SOLZ'],
      'ROLE_EVAL' : ['ROLE_AVO'],
      'ROLE_ADMIN': ['ROLE_EVAL'],
      'ROLE_SUPER_ADMIN': ['ROLE_ADMIN']
    };

    return (rs.containsKey(rol)) ? rs[rol]! : [];
  }

}

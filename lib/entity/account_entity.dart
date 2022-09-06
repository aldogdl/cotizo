import 'package:hive/hive.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;


part 'account_entity.g.dart';

@HiveType(typeId: 10)
class AccountEntity extends HiveObject {

  // flutter packages pub run build_runner build

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  String displayName = '';

  @HiveField(2)
  String email = '';

  @HiveField(3)
  String? photoUrl;

  @HiveField(4)
  String serverToken = '';

  @HiveField(5)
  String msgToken = '';

  @HiveField(6)
  String curc = '';

  @HiveField(7)
  List<String> roles = [];

  ///
  void fromLoginGoogle(GoogleSignInAccount user) {

    id = 0;
    displayName = user.displayName ?? '';
    email = user.email;
    photoUrl = user.photoUrl ?? '';
    serverToken = '0';
    msgToken = '0';
    curc = '0';
    roles = <String>[];
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'serverToken': serverToken,
      'msgToken': msgToken,
      'curc': curc,
      'roles': roles,
    };
  }

}

class AccountEntity {

  int id = 0;
  String displayName = '';
  String email = '';
  String? photoUrl;
  int? serverAuthCode;

  ///
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'serverAuthCode': serverAuthCode,
    };
  }
}
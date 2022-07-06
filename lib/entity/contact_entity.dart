import 'package:hive/hive.dart';

part 'contact_entity.g.dart';

@HiveType(typeId: 4)
class ContactEntity extends HiveObject {

  @HiveField(0)
  int id = 0;

  @HiveField(1)
  String curc = '0';

  @HiveField(2)
  String nombre = '0';

  @HiveField(3)
  String celular = '0';

  @HiveField(4)
  String empresa = '0';

  @HiveField(5)
  String enombre = '0';
  
}
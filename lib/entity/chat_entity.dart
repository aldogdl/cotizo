import '../vars/enums.dart';

class ChatEntity {

  int id = 1;
  ChatFrom from;
  ChatKey key;
  Campos campo;
  String value;
  ChatTip tipo;
  bool procesado;
  bool enviado;
  ChatEntity({
    required this.id,
    required this.from,
    required this.key,
    required this.campo,
    required this.value,
    this.tipo = ChatTip.dialog,
    this.procesado = false,
    this.enviado = false,
  });

  ///
  Map<String, dynamic> toJson() {

    return {
      'id': id,
      'from': from,
      'key': key,
      'campo': campo,
      'value': value,
      'tipo': tipo,
      'procesado': procesado,
      'enviado': enviado,
    };
  }
}
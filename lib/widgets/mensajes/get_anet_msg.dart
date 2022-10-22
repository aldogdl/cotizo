
import 'dialogs.dart';
import '../../entity/chat_entity.dart';
import '../../vars/enums.dart';

class GetAnet {

  /// Revisamos si el ultimo mensaje en pantalla es necesario realizar una
  /// respuesta automatica.
  static Future<ChatEntity?> msg(ChatKey lastkey, {
    required int id, required int modo,
    List<String> params = const []
  }) async {

    await _wait();
    ChatEntity chat = ChatEntity(
      campo: Campos.none,
      id: id, from: ChatFrom.anet, key: ChatKey.estasListo, value: ''
    );
    
    // El case indica el mensaje actual que esta en pantalla
    // En el cuerpo del case indicamos cual es el siguiente mensaje que se insertará
    switch (lastkey) {
      case ChatKey.none: //hidden
        chat.value= DialogsOf.getTime(modo: modo);
        chat.key  = ChatKey.getTime;
        chat.tipo = ChatTip.msg;
        break;
      case ChatKey.getTime:
        chat.value= DialogsOf.estasListo();
        chat.key  = ChatKey.estasListo;
        chat.tipo = ChatTip.interactive;
        break;
      case ChatKey.getAlertFotosLogos: //hidden
        chat.value= DialogsOf.fotosAlert();
        chat.key  = ChatKey.alertFotosLogos;
        chat.tipo = ChatTip.msg;
        break;
      case ChatKey.alertFotosLogos:
        chat.value= DialogsOf.fotos(modo: modo);
        chat.key  = ChatKey.rFotos;
        chat.tipo = ChatTip.dialogFrm;
        break;
      case ChatKey.getAwaitFotos: //hidden
        chat.value = DialogsOf.errAwaitFotos(modo: modo);
        chat.key = ChatKey.errAwaitFotos;
        chat.tipo = ChatTip.interactive;
        break;
      case ChatKey.putDeta: //hidden
        chat.value= DialogsOf.detalles(modo: modo);
        chat.key  = ChatKey.rDeta;
        chat.tipo = ChatTip.dialogFrm;
        break;
      case ChatKey.putCosto: //hidden
        chat.value= DialogsOf.costo(modo: modo);
        chat.key  = ChatKey.rCosto;
        chat.tipo = ChatTip.dialogFrm;
        break;
      case ChatKey.checkData: //hidden
        chat.value= DialogsOf.checkData(modo: modo, params: params);
        chat.key  = ChatKey.checkData;
        chat.tipo = ChatTip.dialog;
        break;
      default:
        return null;
    }

    return chat;
  }

  ///
  static Future<void> _wait() async => await Future.delayed(
    const Duration(milliseconds: 300)
  );
}
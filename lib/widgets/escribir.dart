import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../entity/chat_entity.dart';
import '../providers/gest_data_provider.dart';
import 'show_dialogs.dart';
import '../services/my_image/my_im.dart';
import '../vars/constantes.dart';
import '../vars/enums.dart';
import '../vars/globals.dart';

class Escribir extends StatefulWidget {

  final ValueChanged<ChatEntity> onSend;
  final ValueChanged<void> onClose;
  const Escribir({
    Key? key,
    required this.onSend,
    required this.onClose,
  }) : super(key: key);

  @override
  State<Escribir> createState() => _EscribirState();
}

class _EscribirState extends State<Escribir> {

  final TextEditingController _txtCtr = TextEditingController();
  final ValueNotifier<bool> _showCamera = ValueNotifier<bool>(true);
  final Globals _globals = getIt<Globals>();

  late final GestDataProvider _prov;

  bool _isInit = false;
  double _alto = 0.1;
  double _nuevoAlto = 0.1;
  int _indexBig = 0;
  TextAlignVertical _align = TextAlignVertical.center;

  @override
  void dispose() {
    _txtCtr.dispose();
    _showCamera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!_isInit) {
      _isInit = true;
      _prov = context.read<GestDataProvider>();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * _alto,
      color: _globals.bgMain,
      child: Row(
        children: [
          IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () async => widget.onClose(null),
            icon: Icon(Icons.close, color: _globals.txtOnsecMainLigth),
          ),
          Expanded(
            child: TextField(
              controller: _txtCtr,
              textInputAction: TextInputAction.newline,
              expands: true,
              maxLines: null,
              onChanged: (txt) => _changeSizeTextBox(txt),
              onSubmitted: (txt) => _sendMsg(),
              onEditingComplete: () => _sendMsg(),
              textAlignVertical: _align,
              style: TextStyle(
                color: _globals.txtOnsecMainLigth,
                fontSize: 17
              ),
              decoration: InputDecoration(
                filled: true,
                contentPadding: const EdgeInsets.only(
                  left: 20, right: 0, top: 8, bottom: 8
                ),
                fillColor: _globals.secMain,
                border: _styleBorde(),
                focusedBorder: _styleBorde(),
                suffixIcon: ValueListenableBuilder<bool>(
                  valueListenable: _showCamera,
                  builder: (_, show, child) {
                    return (show) ? child! : const SizedBox(height: 0, width: 0);
                  },
                  child: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Spacer(),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          constraints: const BoxConstraints(
                            minWidth: 40
                          ),
                          onPressed: () => _getFoto('g'),
                          icon: Icon(Icons.attach_file, color: _globals.txtOnsecMainLigth),
                        ),
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () => _getFoto('c'),
                          icon: Icon(Icons.camera_alt, color: _globals.txtOnsecMainLigth),
                        ),
                        const SizedBox(width: 5)
                      ],
                    ),
                  )
                ),
                hintText: 'Escribir',
                hintStyle: TextStyle(
                  color: _globals.txtOnsecMainDark,
                  fontSize: 17
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF51a985),
            child: IconButton(
              onPressed: () => _sendMsg(from: 'btn'),
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  ///
  void _changeSizeTextBox(String txt) {

    final changes = [1.03,1.5,2.37, 2.40];

    var cant = (txt.length / 46);
    final tot = cant.toStringAsFixed(2);
    cant = double.parse(tot);

    if(cant < changes.first) {
      _nuevoAlto = 0.1;
    }else{
      if(_indexBig < changes.length) {
        double lasValue = (changes.length < (_indexBig+1)) ?  _indexBig+1 : changes.last;
        if(cant >= changes[_indexBig] && cant < lasValue) {
          _nuevoAlto = _nuevoAlto + 0.05;
        }
      }
    }

    bool refresh = true;
    if(_alto != _nuevoAlto) {
      if(txt.length <= 46) {
        if(_alto != 0.1) {
          _indexBig = 0;
          _alto = 0.1;
          _align = TextAlignVertical.center;
        }else{
          refresh = false;
        }
      }else{
        _indexBig++;
        _alto = _alto + 0.05;
        _align = TextAlignVertical.top;
      }
      if(refresh) {
        setState(() {});
      }
    }

    _showCamera.value = (txt.isNotEmpty) ? false : true;
  }

  ///
  OutlineInputBorder _styleBorde() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(25),
      borderSide: const BorderSide(
        color: Colors.transparent
      )
    );
  }

  ///
  void _sendMsg({String from = 'keyboard'}) async {

    if(_txtCtr.text.isNotEmpty) {
      widget.onSend(
        ChatEntity(
          id: _prov.msgs.length+1,
          from: ChatFrom.user,
          campo: _prov.currentCampo,
          key: ChatKey.userRes,
          value: _txtCtr.text,
        )
      );
      _txtCtr.text = '';
      _changeSizeTextBox('');
    }

    // if(from != 'keyboard') {
    //   FocusManager.instance.primaryFocus?.unfocus();
    // }else{
    //   if(_txtCtr.text.isEmpty) {
    //     FocusManager.instance.primaryFocus?.unfocus();
    //   }
    // }
  }

  ///
  Future<void> _getFoto(String src) async {

    if(_prov.campos[Campos.rFotos].length == Constantes.cantFotos) {

      ShowDialogs.alert(
        context, 'fotosCant',
        hasActions: false
      ).then((res){
        res = (res == null) ? false : res;
        if(res) {
          widget.onClose(null);
        }
      });
      return;
    }

    List<XFile>? imgs = [];

    if(src == 'c') {
      XFile? img = await MyIm.camera();
      if(img != null) {
        imgs.add(img);
      }
    }

    if(src == 'g') {
      imgs = await MyIm.galeria();
    }

    if(imgs != null) {
      
      if(imgs.isNotEmpty) {

        List<String> imgPaths = [];
        for(var i = 0; i < imgs.length; i++) {
          if(i < Constantes.cantFotos) {
            imgPaths.add(imgs[i].path);
          }
        }

        if(imgPaths.isNotEmpty) {

          _prov.campos[Campos.rFotos] = List<String>.from(imgPaths);
          for(var i = 0; i < imgPaths.length; i++) {
            widget.onSend(
              ChatEntity(
                id: _prov.msgs.length+1,
                from: ChatFrom.user,
                key: ChatKey.userRes,
                campo: _prov.currentCampo,
                value: imgPaths[i],
              )
            );
            await Future.delayed(const Duration(milliseconds: 350));
          }
        }
      }
    }
  }


}
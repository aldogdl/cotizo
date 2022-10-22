import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/sngs_manager.dart';
import '../entity/chat_entity.dart';
import '../providers/gest_data_provider.dart';
import '../vars/enums.dart';
import '../vars/globals.dart';

class EscribirLong extends StatefulWidget {

  final ValueChanged<ChatEntity> onSend;
  final ValueChanged<void> onClose;
  const EscribirLong({
    Key? key,
    required this.onSend,
    required this.onClose,
  }) : super(key: key);

  @override
  State<EscribirLong> createState() => _EscribirLongState();
}

class _EscribirLongState extends State<EscribirLong> {

  final FocusNode _focus = FocusNode();

  final TextEditingController _txtCtr = TextEditingController();
  final Globals _globals = getIt<Globals>();

  late final GestDataProvider _prov;

  String _keyboardCurrent = 'txt';
  bool _isInit = false;
  double _alto = 0.09;
  double _nuevoAlto = 0.1;
  int _indexBig = 0;
  TextAlignVertical _align = TextAlignVertical.center;

  @override
  void dispose() {
    _txtCtr.dispose();
    _focus.dispose();
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
      child: Row(
        children: [
          IconButton(
            padding: const EdgeInsets.all(0),
            visualDensity: VisualDensity.compact,
            onPressed: () async => widget.onClose(null),
            icon: Icon(Icons.close, color: _globals.txtOnsecMainLigth),
          ),
          Expanded(
            child: Selector<GestDataProvider, String>(
              selector: (_, provi) => provi.changeKeyboard,
              builder: (_, changeTo, child) {

                _switch(changeTo);
                return (changeTo == 'num')
                ? _txtFieldNumber()
                : child!;
              },
              child: _txtFieldTxt(),
            )
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
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
  Widget _txtFieldTxt() => _txtField( expands: true );

  ///
  Widget _txtFieldNumber() {

    return _txtField(
      textInputAction: TextInputAction.go,
      keyboardType: TextInputType.number,
      expands: true
    );

  }

  ///
  Widget _txtField({
    required bool expands,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int? maxLines }) 
  {

    return TextField(
      controller: _txtCtr,
      focusNode: _focus,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      expands: expands,
      maxLines: maxLines,
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
          left: 20, right: 15, top: 8, bottom: 8
        ),
        fillColor: _globals.secMain,
        border: _styleBorde(),
        focusedBorder: _styleBorde(),
        hintText: 'Escribir...',
        hintStyle: TextStyle(
          color: _globals.txtOnsecMainDark,
          fontSize: 17
        ),
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
  }

  ///
  OutlineInputBorder _styleBorde() {

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(
        color: Colors.transparent
      )
    );
  }

  ///
  void _sendMsg({String from = 'keyboard'}) async {

    if(_txtCtr.text.isNotEmpty) {

      if(_prov.currentCampo == Campos.rDeta) {
        _prov.imgTmps = 0;
      }

      _prov.campos[_prov.currentCampo] = _txtCtr.text;
      widget.onSend(
        ChatEntity(
          id: _prov.msgs.length+1,
          from: ChatFrom.user,
          key: ChatKey.userRes,
          campo: _prov.currentCampo,
          value: _txtCtr.text,
        )
      );
      _txtCtr.text = '';
      _changeSizeTextBox('');
    }
  }

  ///
  void _switch(String changeTo) {

    if(_prov.currentCampo == Campos.isCheckData) {
      _focus.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
    }else{

      if(_keyboardCurrent != changeTo) {
        _keyboardCurrent = changeTo;
        _focus.unfocus();
        Future.delayed(const Duration(milliseconds: 350), (){
          setState(() {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _focus.requestFocus(),
            );
          });
        });
      }
    }
  }

}
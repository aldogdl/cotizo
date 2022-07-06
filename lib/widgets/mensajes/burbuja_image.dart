import 'dart:io';
import 'package:cotizo/services/my_image/my_im.dart';
import 'package:cotizo/vars/constantes.dart';
import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/sngs_manager.dart';
import '../../entity/chat_entity.dart';
import '../../providers/gest_data_provider.dart';
import '../../vars/enums.dart';
import '../../vars/globals.dart';
import 'burbuja_piquito.dart';

class BurbujaImage extends StatelessWidget {

  final ChatEntity msg;
  BurbujaImage({
    Key? key,
    required this.msg,
  }) : super(key: key);

  final Globals _globals = getIt<Globals>();

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: Key('${msg.id}'),
      confirmDismiss: (direcc) => Future.value(true),
      onDismissed: (direcc) {
        context.read<GestDataProvider>().editMsgs(msg);
      },
      child: _burguja(context)
    );
  }

  ///
  Widget _burguja(BuildContext context) {

    double radius = 10;
    double alto = 250;
    double margin = MediaQuery.of(context).size.width * Constantes.marginBubble;
    Widget piquito = CustomPaint(
      size: const Size(20, 20),
      painter: BurbujaPiquito(
        bg: (msg.from == ChatFrom.anet) ? _globals.secMain : _globals.colorBurbbleResp,
        from: msg.from
      ),
    );
    
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: alto,
        margin: (msg.from == ChatFrom.anet)
        ? EdgeInsets.only(right: margin, left: 0)
        : EdgeInsets.only(left: margin, right: 0),
        child: LayoutBuilder(
          builder: (_, restrics) {
            return Column(
              crossAxisAlignment: (msg.from == ChatFrom.anet)
              ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: restrics.maxWidth,
                        height: alto,
                        padding: const EdgeInsets.all(10),
                        margin: (msg.from == ChatFrom.anet)
                        ? const EdgeInsets.only(left: 10)
                        : const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: (msg.from == ChatFrom.anet)
                          ? _globals.secMain
                          : _globals.colorBurbbleResp,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(radius),
                            bottomRight: Radius.circular(radius),
                            bottomLeft: Radius.circular(radius),
                          )
                        ),
                        child: SizedBox.expand(
                          child: _img(restrics, context.read<GestDataProvider>())
                        )
                      ),
                      (msg.from == ChatFrom.anet) ? _topAnet(piquito) : _topResp(piquito)
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  ///
  Widget _img(BoxConstraints restrics, GestDataProvider prov) {

    return StreamBuilder<Map<String, dynamic>>(
      stream: _procesarImage(prov),
      initialData: {'blur':3.0, 'msg':prov.pasosImgs.first},
      builder: (_, AsyncSnapshot snap) {

        if(snap.data == null) {
          return _imageClean(restrics);
        }
        if(snap.data['msg'].contains('ok')) {
          return _imageClean(restrics);
        }
        return _blur(restrics, prov, snap.data);
      },
    );
  }

  ///
  Widget _blur(BoxConstraints restrics, GestDataProvider prov, Map<String, dynamic> proc) {

    return Blur(
      alignment: Alignment.center,
      blur: proc['blur'],
      colorOpacity: 0.2,
      blurColor: Colors.black,
      borderRadius: BorderRadius.circular(8),
      overlay: _txtProcesos(restrics, proc['msg']),
      child: _imageClean(restrics)
    );
  }

  ///
  Widget _imageClean(BoxConstraints restrics) {

    return Image.file(
      File(msg.value),
      alignment: Alignment.center,
      fit: BoxFit.cover,
      width: restrics.maxWidth,
    );
  }

  ///
  Widget _txtProcesos(BoxConstraints restrics, String proc) {

    return Container(
      width: restrics.maxWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _globals.txtOnsecMainDark
                ),
              ),
              const SizedBox(width: 10),
              Text(
                proc,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Colors.yellow.withOpacity(0.7)
                ),
              )
            ],
          ),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
  
  ///
  Widget _topAnet(Widget child) => Positioned(top: 0, left: 0, child: child);

  ///
  Widget _topResp(Widget child) => Positioned(top: 0, right: 0, child: child);

  ///
  Stream<Map<String, dynamic>> _procesarImage(GestDataProvider prov) async* {

    if(msg.procesado) {
      Map<String, dynamic> resp = {
        'blur': 0, 'msg': prov.pasosImgs.last
      };
      yield resp;
      return;
    }

    int index = 1;
    double blur = 3.0;
    double step = blur / prov.pasosImgs.length;
    Map<String, dynamic> resp = {
      'blur': blur, 'msg': prov.pasosImgs[index]
    };
    yield resp;
    await Future.delayed(const Duration(milliseconds: 500));

    // Minificando
    final result = await MyIm.prepareImage(
      foto: XFile(msg.value),
      minWidth: 1024,
      minHeight: 720
    );
    result['thub'] = await MyIm.prepareImage(data: result['res']['data']);

    index++;
    resp = {
      'blur': (resp['blur']-step), 'msg': prov.pasosImgs[index]
    };
    yield resp;
    await Future.delayed(const Duration(milliseconds: 500));

    //Notificando
    index++;
    resp = {
      'blur': (resp['blur']-step), 'msg': prov.pasosImgs[index]
    };
    yield resp;
    await Future.delayed(const Duration(milliseconds: 500));

    //Organizando en Local
    index++;
    resp = {
      'blur': (resp['blur']-step), 'msg': prov.pasosImgs[index]
    };
    yield resp;
    await Future.delayed(const Duration(milliseconds: 500));

    //Respaldando
    index++;
    resp = {
      'blur': (resp['blur']-step), 'msg': prov.pasosImgs[index]
    };
    yield resp;
    await Future.delayed(const Duration(milliseconds: 500));

    //fin ok
    resp = {
      'blur': (resp['blur']-step), 'msg': prov.pasosImgs.last
    };
    yield resp;
    msg.procesado = true;
    await Future.delayed(const Duration(milliseconds: 500));
  }

}
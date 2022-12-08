import 'dart:io';

import 'package:cotizo/vars/constantes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'mensajes/dialogs.dart';
import '../entity/pieza_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/signin_provider.dart';
import '../repository/acount_user_repository.dart';
import '../repository/config_app_repository.dart';
import '../services/my_get.dart';
import '../services/my_paths.dart';
import '../services/my_image/my_im.dart';
import '../services/utils_services.dart';
import '../vars/globals.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/view_fotos.dart';

class TileOrdenPieza extends StatelessWidget {

  final PiezaEntity pieza;
  final int idAuto;
  final int idOrden;
  final DateTime created;
  final List<String> fotos;
  final String requerimientos;
  final String callFrom;
  final SharedDataOrden box;
  final int isInv;
  final ValueChanged<int>? onDelete;
  final ValueChanged<Map<String, dynamic>> onNtg;
  final ValueChanged<int> onCot;
  final ValueChanged<int>? onApartar;
  const TileOrdenPieza({
    Key? key,
    required this.pieza,
    required this.idAuto,
    required this.idOrden,
    required this.created,
    required this.fotos,
    required this.requerimientos,
    required this.box,
    required this.onNtg,
    required this.onCot,
    required this.callFrom,
    this.onApartar,
    this.isInv = 0,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, null);
    Mget.size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width,
        height: (MediaQuery.of(context).size.height / 2.5)
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Mget.globals.secMain,
        border: Border.all(color: const Color.fromARGB(255, 112, 112, 112)),
      ),
      child: FutureBuilder(
        future: _getDatos(),
        builder: (_, __) => _body(context),
      ),
    );
  }

  ///
  Widget _body(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _visor(context),
                  child: _foto(),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dataItem(context),
                  _detallesPza(),
                ],
              ),
            ],
          )
        ),
        Divider(color: Colors.grey.withOpacity(0.8)),
        (isInv != 0) ? _pieInv() : _pie(context)
      ],
    );
  }

  ///
  Widget _detallesPza() {

    String req = UtilServices.getRequerimientos(requerimientos);

    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 10, bottom: 3, left: 10),
      child: Text.rich(
        TextSpan(
          text: 'NOTAS: ',
          style: const TextStyle(color: Color.fromARGB(255, 245, 134, 100)),
          children: [
            TextSpan(
              text: req,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.2
              )
            )
          ]
        ),
        textScaleFactor: 1,
        style: const TextStyle(
          fontSize: 16,
        ),
      )
    );
  }

  ///
  Widget _foto() {

    var auto = 'AUTO DESCONOCIDO';
    if(box.marca != null && box.modelo != null) {
      auto = '${box.marca!.nombre} ${box.modelo!.nombre}';
    }
    final globals = Globals();
    final fecha = '${created.day}/${created.month}/${created.year}';
    
    return SizedBox(
      width: Mget.size.width,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              child: (isInv != 0) ? _getImgFromFile() : _getImgFromWeb()
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Row(
                children: [
                  Text(
                    auto,
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: globals.colorGreen,
                      fontSize: 17
                    ),
                  ),
                  const Spacer(),
                  Text(
                    (box.auto == null)
                    ? '0000' : '${box.auto!.anio}',
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: globals.colorGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(15),
                )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Row(
                  children: [
                    if(isInv == 0)
                    ...[
                      Text(
                        'ID: $idOrden',
                        textScaleFactor: 1,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.date_range, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        fecha,
                        textScaleFactor: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12
                        ),
                      ),
                    ]
                  else
                    Text(
                      (box.inv == null)
                        ? 'Inventario' : 'ID: [ ${box.inv!.id} ]',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12
                      ),
                    ),
                  ],
                )
              ),
            )
          )
        ],
      ),
    );
  }
  
  ///
  Widget _getImgFromWeb() {

    if(fotos.isEmpty) {
      return const SizedBox(
        child: Icon(Icons.no_photography_outlined, size: 100, color: Colors.grey)
      );
    }

    return CachedNetworkImage(
      imageUrl: MyPath.getUriFotoPieza(fotos.first, isThubm: true),
      fit: BoxFit.cover,
      alignment: Alignment.center,
      placeholder: (_, data) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

  }
  
  ///
  Widget _getImgFromFile() {

    return FutureBuilder<File?>(
      future: MyIm.getImageByPath(fotos.first),
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {
          if(snap.data != null) {
            return Image.file(
              snap.data,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            );
          }else{
            return Icon(Icons.photo_size_select_small_rounded, color: Mget.globals.bgMain, size: 100);
          }
        }

        return const Center( child: CircularProgressIndicator() );
      },
    );
  }

  ///
  Widget _dataItem(BuildContext context) {

    return Container(
      width: Mget.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: _dataPza(context)
          ),
        ],
      ),
    );
  }

  ///
  Widget _dataPza(BuildContext context) {

    String nombrePza = (pieza.id == 0) ? 'SIN NOMBRE' : pieza.piezaName;
    if(nombrePza.length > 28){
      nombrePza = '${nombrePza.substring(0, 25).trim()}...';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: () async => (isInv != 0) ? null : onCot(pieza.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombrePza,
                  textScaleFactor: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  (pieza.id == 0)
                    ? 'LADO Y POSICIÓN'
                    : '${pieza.lado} ${pieza.posicion}',
                  textScaleFactor: 1,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if(onApartar != null)
            _btnApartar(context)
          else
            if(isInv == 0)
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.grey.withOpacity(0.5))
                ),
                child: const Icon(Icons.check, color: Colors.green, size: 18),
              )
            else
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: Colors.grey.withOpacity(0.5))
                ),
                child: const Icon(Icons.date_range, color: Color.fromARGB(255, 104, 104, 104), size: 18),
              )
        ],
      )
    );
  }

  ///
  Widget _btnApartar(BuildContext context) {

    final cfg = ConfigAppRepository();

    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(const EdgeInsets.all(0))
      ),
      onPressed: () async {
        // await cfg.setShowDialogApartar(true);
        bool? acc = (await cfg.getShowDialogApartar())
          ? await _showDialogApartar(context, cfg)
          : true;
        acc = (acc == null) ? false : acc;
        if(acc) { onApartar!(pieza.id); }
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.green)
            ),
            child: const Icon(Icons.favorite, color: Color.fromARGB(255, 235, 137, 80), size: 18),
          ),
          const SizedBox(height: 5),
          Text(
            'APARTAR',
            textScaleFactor: 1,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.05
            ),
          ),
        ],
      )
    );
  }

  ///
  Widget _pie(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(width: 5),
          _btnNot(Icons.no_stroller_rounded, 'NO LA TENGO', () async {

            _showDialogNt(context).then((acc) async {
              
              acc = (acc == null) ? false : acc;
              if(acc) {
                final isGo = await _isAuthorized(context);
                if(isGo) {
                  onNtg({'idPza': pieza.id, 'from': Constantes.convertTo(callFrom)});
                }
              }
            });
          }),
          const Spacer(),
          Selector<SignInProvider, bool>(
            selector: (_, prov) => prov.isLogin,
            builder: (_, val, __) {

              return ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: (val) 
                    ? MaterialStateProperty.all(Colors.green)
                    : MaterialStateProperty.all(const Color.fromARGB(255, 81, 169, 133))
                ),
                onPressed: () async => (isInv != 0) ? null : onCot(pieza.id),
                icon: const Icon(Icons.monetization_on_outlined, color: Colors.black),
                label: const Text(
                  'COTIZAR',
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 15,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1,1)
                      )
                    ]
                  ),
                )
              );
            },
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  ///
  Widget _pieInv() {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          _btnNot(Icons.remove_shopping_cart, 'ELIMINAR', () => onDelete!(isInv)),
          const Spacer(),
          _btnNot(Icons.share, 'COMPARTIR', () async => await _compartir()),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  ///
  Widget _btnNot(IconData icono, String label, Function fnc) {

    Color color = Colors.green;
    final globals = Globals();
    if(icono == Icons.share) {
      color = const Color.fromARGB(255, 235, 155, 6);
    }

    Color txtC = const Color.fromARGB(255, 207, 207, 207);
    if(label.startsWith('COMPARTIR')) {
      txtC = globals.colorGreen;
    }

    if(icono == Icons.monetization_on_outlined) {
      color = globals.colorGreen;
      txtC = Colors.grey;
      if(Mget.auth!.isLogin) {
        txtC = Colors.orange;
      }
    }

    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 51, 67, 77)),
      ),
      onPressed: () => fnc(),
      icon: Icon(icono, color: color, size: 15,),
      label: Text(
        label,
        textScaleFactor: 1,
        style: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: txtC 
        ),
      )
    );
  }

  ///
  Widget _widgetForDialogApartar(bool isCheck, {required ValueChanged<bool> onCheck}) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Podrás cotizarlas más tarde',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18
          ),
        ),
        const Divider(color: Colors.green),
        Text(
          'Recorre la lista de solicitudes y ve APARTANDO '
          'piezas con las que cuentas en tu inventario físico.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7)
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Podrás visualizar la autopartes en la sección de APARTADOS, '
          'donde podrás fácilmente eliminarlas posteriormente.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.greenAccent
          ),
        ),
        const Divider(color: Colors.green),
        Center(
          child: CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.all(0),
            checkColor: Colors.white,
            activeColor: Colors.blueAccent,
            side: const BorderSide(color: Colors.white),
            title: const Text(
              'NO MOSTRAR',
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17
              ),
            ),
            subtitle: const Text(
              'nuevamente este aviso',
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14
              ),
            ),
            value: isCheck,
            onChanged: (val) => onCheck(val ?? false)
          ),
        )
      ],
    );
  }

  ///
  void _visor(BuildContext context) async {

    await showDialog(
      context: context,
      builder: (_) => ShowDialogs.visorFotosDialog(
        context, ViewFotos(
          fotosList: fotos,
          bySrc: (isInv != 0) ? 'inventario' : 'network',
        )
      )
    );
  }

  ///
  Future<bool> _isAuthorized(BuildContext context) async {

    if(!Mget.auth!.isLogin) {
      final usEm = AcountUserRepository();
      usEm.getDataUserInLocal().then((hasDta) async {
        if(hasDta.id == 0) {
          await _showDialogLogin(context);
        }else{
          context.push('/login');
        }
      });
      return false;
    }else{
      return true;
    }
  }

  ///
  Future<bool?> _showDialogNt(BuildContext context) async {

    return await ShowDialogs.alert(
      context, 'noTengo',
      hasActions: true,
      labelNot: 'CANCELAR',
      labelOk: 'CONTINUAR'
    );
  }

  ///
  Future<void> _showDialogLogin(BuildContext context) async {

    await ShowDialogs.alert(
      context, 'noLogin',
      hasActions: true,
      labelNot: 'NO',
      labelOk: 'AUTENTICARME'
    ).then((bool? acc) {

      acc = (acc == null) ? false : acc;
      if(acc) {
        context.push('/login');
      }
    });
  }

  ///
  Future<bool?> _showDialogApartar(BuildContext context, ConfigAppRepository c) async {

    bool showDialogApartar = false;

    return await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => AlertDialog(
        backgroundColor: Globals().bgMain,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        title: Text(
          'APARTAR PIEZA ${ DialogsOf.icon('fine') }',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueAccent
          ),
        ),
        content: StatefulBuilder(
          builder: (_, StateSetter setState) {

            return _widgetForDialogApartar(
              showDialogApartar,
              onCheck: (bool val) async {
                await c.setShowDialogApartar(!val);
                setState((){ showDialogApartar = val; });
              }
            );
          }
        ),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white)
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'CANCELAR',
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold
              ),
            )
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'APARTAR',
              textScaleFactor: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            )
          )
        ],
      ),
    );
  }

  ///
  Future<void> _getDatos() async {

    final em = box.solEm;
    
    // Iniciamos todas las cajas necesarias
    await box.solEm.initBoxes();
    box.auto = await em.getAutoById(idAuto);
    if(box.auto != null) {
      box.marca = await em.getMarcaById(box.auto!.marca);
      box.modelo = await em.getModeloById(box.auto!.modelo);
    }
    
    if(isInv != 0) {
      box.inv = await em.getInvById(isInv);
    }
  }

  ///
  Future<void> _compartir() async {

    List<XFile> send = [];
    for (var i = 0; i < fotos.length; i++) {
      XFile? file = await MyIm.getXFileByPath(fotos[i]);
      if(file != null) {
        send.add(file);
      }
    }
    if(send.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: getMessage()));
      await Share.shareXFiles(send);
    }
  }

  ///
  String getMessage() {

    return ''
    '\n'
    '*${pieza.piezaName}* ${pieza.lado} ${pieza.posicion}'
    '\n'
    '${box.inv!.deta}.'
    '\n'
    '--------------------------------------'
    '\n'
    '🚘 *${box.modelo!.nombre}* ${box.auto!.anio} ${box.marca!.nombre}'
    '\n'
    '--------------------------------------'
    '\n'
    'Id: *$isInv*';
  }


}
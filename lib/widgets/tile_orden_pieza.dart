
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../entity/pieza_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/signin_provider.dart';
import '../repository/acount_user_repository.dart';
import '../services/my_get.dart';
import '../services/my_image/my_im.dart';
import '../vars/my_paths.dart';
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
  final SharedDataOrden box;
  final String idsFromLink;
  final int isInv;
  final ValueChanged<int>? onDelete;
  final ValueChanged<int>? onNt;
  const TileOrdenPieza({
    Key? key,
    required this.pieza,
    required this.idAuto,
    required this.idOrden,
    required this.created,
    required this.fotos,
    required this.requerimientos,
    required this.box,
    this.idsFromLink = '',
    this.isInv = 0,
    this.onDelete,
    this.onNt,
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
        border: Border.all(color: const Color.fromARGB(255, 75, 75, 75)),
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
                  onTap: () => _visor(),
                  child: _foto(),
                ),
              ),
              InkWell(
                onTap: () async => (isInv != 0) ? null : _gestionarDatos(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _dataItem(),
                    _detallesPza(),
                  ],
                ),
              )
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

    String req = (requerimientos.length > 225)
      ? '${requerimientos.substring(0, 225)}...' : requerimientos;

    req = (req == '0' || req.isEmpty) ? 'En las mejores condiciones.' : req;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Text.rich(
        TextSpan(
          text: 'NOTAS: ',
          style: const TextStyle(color: Color.fromARGB(255, 245, 134, 100)),
          children: [
            TextSpan(
              text: req,
              style: const TextStyle(
                color: Colors.grey
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
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.zoom_out_map, color: Colors.white),
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
      imageUrl: MyPath.getUriFotoPieza(fotos.first),
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
  Widget _dataItem() {

    return Container(
      width: Mget.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: _dataPza()
          ),
        ],
      ),
    );
  }

  ///
  Widget _dataPza() {

    final fecha = '${created.day}/${created.month}/${created.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                (pieza.id == 0)
                ? 'SIN NOMBRE' : pieza.piezaName,
                textScaleFactor: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17
                ),
              ),
              const Spacer(),
              Text(
                fecha,
                textScaleFactor: 1,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
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
              if(isInv == 0)
                ...[
                  Text(
                    'No. Orden $idOrden',
                    textScaleFactor: 1,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
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
        ],
      ),
    );
  }

  ///
  Widget _pie(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _btnNot(Icons.no_stroller_rounded, 'NO LA TENGO', () async {

            _showDialogNt(context).then((acc) async {
              
              acc = (acc == null) ? false : acc;
              if(acc) {
                final isGo = await _isAuthorized(context);
                if(isGo) {
                  onNt!(pieza.id);
                }
              }
            });
          }),
          Selector<SignInProvider, bool>(
            selector: (_, prov) => prov.isLogin,
            builder: (_, val, __) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () async => (isInv != 0) ? null : _gestionarDatos(context),
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
                ),
              );
            },
          )
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

    Color color = Colors.white;
    final globals = Globals();
    if(icono == Icons.share) {
      color = const Color.fromARGB(255, 235, 155, 6);
    }
    
    Color txtC = const Color(0xFF798892);
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

    return TextButton.icon(
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
  void _visor() async {

    await showDialog(
      context: Mget.ctx!,
      builder: (_) => ShowDialogs.visorFotosDialog(
        Mget.ctx!, ViewFotos(
          fotosList: fotos,
          bySrc: (isInv != 0) ? 'inventario' : 'network',
        )
      )
    );
  }

  ///
  void _gestionarDatos(BuildContext context) async {
    
    final nav = GoRouter.of(context);

    Mget.globals.idOrdenCurrent = idOrden;
    if(idsFromLink.isNotEmpty) {
      final partes = idsFromLink.split('-');
      if(partes.length > 3) {
        Mget.globals.idsFromLinkCurrent = idsFromLink;
        Mget.globals.idCampaingCurrent = partes[3];
      }else{
        Mget.globals.idsFromLinkCurrent = '';
        Mget.globals.idCampaingCurrent = '';
      }
    }
  
    final isGo = await _isAuthorized(context);
    if(isGo) {
      nav.go('/gest-data/${pieza.id}');
    }
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
      labelOk: 'ELIMINAR'
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
  Future<void> _getDatos() async {

    final em = box.solEm;
    if(box.auto == null) {
      // Iniciamos todas las cajas necesarias
      await box.solEm.initBoxes();
      box.auto = await em.getAutoById(idAuto);
      if(box.auto != null) {
        box.marca = await em.getMarcaById(box.auto!.marca);
        box.modelo = await em.getModeloById(box.auto!.modelo);
      }
    }
    
    if(isInv != 0) {
      box.inv = await em.getInvById(isInv);
    }
  }

  ///
  Future<void> _compartir() async {

    List<String> send = [];
    List<File> delets = [];
    for (var i = 0; i < fotos.length; i++) {
      File? path = await MyIm.getImageByPath(fotos[i]);
      Directory dir = await getTemporaryDirectory();
      File otro = await path!.copy('${dir.path}${fotos[i]}');
      send.add(otro.path);
      delets.add(otro);
    }
    Clipboard.setData(ClipboardData(text: getMessage()));
    await Share.shareFiles(send);

    for (var i = 0; i < delets.length; i++) {
      delets[i].deleteSync();
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
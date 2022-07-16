import 'dart:io';

import 'package:cotizo/services/my_image/my_im.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'avatar_logo.dart';
import '../entity/share_data_orden.dart';
import '../services/my_get.dart';
import '../vars/my_paths.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/view_fotos.dart';

class TileOrdenPieza extends StatelessWidget {

  final int idPieza;
  final int idAuto;
  final int idOrden;
  final DateTime created;
  final List<String> fotos;
  final String requerimientos;
  final SharedDataOrden box;
  final String idsFromLink;
  final int isInv;
  final ValueChanged<int>? onDelete;
  const TileOrdenPieza({
    Key? key,
    required this.idPieza,
    required this.idAuto,
    required this.idOrden,
    required this.created,
    required this.fotos,
    required this.requerimientos,
    required this.box,
    this.idsFromLink = '',
    this.isInv = 0,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, null);
    Mget.size = MediaQuery.of(context).size;
    
    if(isInv == 0) {
      if(Mget.globals.invFilter.containsKey(idOrden)) {
        if(Mget.globals.invFilter[idOrden]!.contains(idPieza)) {
          return const SizedBox();
        }
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width,
        height: (MediaQuery.of(context).size.height / 2.5)
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Mget.globals.secMain,
        border: Border.all(color: const Color.fromARGB(255, 75, 75, 75))
      ),
      child: FutureBuilder(
        future: _getDatos(),
        builder: (_, __) => _body(),
      ),
    );
  }

  ///
  Widget _body() {

    String req = (requerimientos.length > 225)
      ? '${requerimientos.substring(0, 225)}...' : requerimientos;
    
    req = (req == '0') ? 'En las mejores condiciones, por favor' : req;

    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async => (isInv != 0) ? null : _gestionarDatos(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _foto(),
                ),
                _dataItem(),
                Padding(
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
                )
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey.withOpacity(0.8)),
        (isInv != 0) ? _pieInv() : _pie()
      ],
    );
  }
  
  ///
  Widget _foto() {

    var auto = 'AUTO DESCONOCIDO';
    if(box.marca != null) {
      auto = '${box.marca!.nombre} ${box.modelo!.nombre}';
    }

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
                    style: const TextStyle(
                      color: Color.fromARGB(255, 85, 230, 90),
                      fontSize: 17
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(box.auto == null) ? 0000 : box.auto!.anio}',
                    textScaleFactor: 1,
                    style: const TextStyle(
                      color: Colors.yellow,
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
              child: IconButton(
                padding: const EdgeInsets.all(0),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.zoom_out_map, color: Colors.white,),
                onPressed: () => _visor(fotos)
              ),
            )
          )
        ],
      ),
    );
  }
  
  ///
  Widget _getImgFromWeb() {

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
          AvatarLogo(logo: (box.marca == null) ? 'no-logo.png' : box.marca!.logo),
          const SizedBox(width: 10),
          Expanded(
            child: _dataPza()
          ),
         if(isInv != 0)
          _iconShare()
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
          Text(
            (box.pieza == null) ? 'SIN NOMBRE' : box.pieza!.piezaName,
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17
            ),
          ),
          const SizedBox(height: 3),
          Text(
            (box.pieza == null) ? 'LADO Y POSICIÓN' : '${box.pieza!.lado} ${box.pieza!.posicion}',
            textScaleFactor: 1,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Publicado: $fecha',
                textScaleFactor: 1,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12
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
                ],
            ],
          )
        ],
      ),
    );
  }

  ///
  Widget _iconShare() {

    return TextButton(
      onPressed: () async => await _compartir(),
      child: CircleAvatar(
        backgroundColor: Mget.globals.colorGreen,
        child: Icon(Icons.share_sharp, color: Mget.globals.secMain),
      ),
    );
  }

  ///
  Widget _pie() {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _btnNot(Icons.no_stroller_rounded, 'NO LA TENGO', (){}),
          const Spacer(),
          _btnNot(Icons.notifications_off_outlined, 'NO LA MANEJO', (){})
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
          _btnNot(Icons.remove_shopping_cart, 'VENDIDA', () => onDelete!(isInv)),
          const Spacer(),
          Text(
            'No. $isInv',
            textScaleFactor: 1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF798892)
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  ///
  Widget _btnNot(IconData icono, String label, Function fnc) {

    return TextButton.icon(
      onPressed: () => fnc(),
      icon: Icon(icono, color: Colors.white, size: 15,),
      label: Text(
        label,
        textScaleFactor: 1,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF798892)
        ),
      )
    );
  }

  ///
  void _visor(List<String> imgs) async {

    await showDialog(
      context: Mget.ctx!,
      builder: (_) => ShowDialogs.visorFotosDialog(
        Mget.ctx!, ViewFotos(
          fotosList: imgs,
          bySrc: (isInv != 0) ? 'inventario' : 'network',
        )
      )
    );
  }

  ///
  void _gestionarDatos() {
    
    if(Mget.auth!.isLogin) {

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
      Mget.ctx!.go('/gest-data/$idPieza');

    }else{
      ShowDialogs.alert(
        Mget.ctx!, 'noLogin',
        hasActions: true,
        labelNot: 'NO',
        labelOk: 'AUTENTICARME'
      ).then((bool? acc) {
        acc = (acc == null) ? false : acc;
        if(acc) {
          Mget.ctx!.push('/login');
        }
      });
    }
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

    box.pieza ??= await em.getPiezaById(idPieza);
    if(isInv != 0) {
      box.inv ??= await em.getInvById(isInv);
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
    '*${box.pieza!.piezaName}* ${box.pieza!.lado} ${box.pieza!.posicion}'
    '\n'
    '${box.inv!.deta}.'
    '--------------------------------------'
    '\n'
    '🚘 *${box.modelo!.nombre}* ${box.auto!.anio} ${box.marca!.nombre}'
    '\n'
    '--------------------------------------'
    '\n'
    'Serie: *$isInv*';
  }
}
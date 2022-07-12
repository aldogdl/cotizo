import 'package:cotizo/providers/ordenes_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../entity/share_data_orden.dart';
import '../services/my_get.dart';
import '../vars/my_paths.dart';
import '../widgets/show_dialogs.dart';
import '../widgets/view_fotos.dart';
import 'avatar_logo.dart';

class TileOrdenPieza extends StatelessWidget {

  final int idPieza;
  final int idAuto;
  final int idOrden;
  final DateTime created;
  final List<String> fotos;
  final SharedDataOrden box;
  const TileOrdenPieza({
    Key? key,
    required this.idPieza,
    required this.idAuto,
    required this.idOrden,
    required this.created,
    required this.fotos,
    required this.box,
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

    return Column(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async => _gestionarDatos(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _foto(),
                ),
                _dataItem()
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              _btnNot(Icons.no_stroller_rounded, 'NO LA TENGO'),
              const Spacer(),
              _btnNot(Icons.notifications_off_outlined, 'NO LA MANEJO')
            ],
          ),
        )
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
              child: CachedNetworkImage(
                imageUrl: MyPath.getUriFotoPieza(fotos.first),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                placeholder: (_, data) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
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
  Widget _dataItem() {

    final fecha = '${created.day}/${created.month}/${created.year}';

    return Container(
      width: Mget.size.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AvatarLogo(logo: (box.marca == null) ? 'no-logo.png' : box.marca!.logo),
          const SizedBox(width: 10),
          Padding(
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
                      'No. Orden $idOrden',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Publicado: $fecha',
                      textScaleFactor: 1,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Widget _btnNot(IconData icono, String label) {

    return TextButton.icon(
      onPressed: (){},
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
        Mget.ctx!, ViewFotos(fotosList: imgs)
      )
    );
  }

  ///
  void _gestionarDatos() {
    
    if(Mget.auth!.isLogin) {

      final ordP = Mget.ctx!.read<OrdenesProvider>();
      ordP.idOrdenCurrent = idOrden;
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
  }

}
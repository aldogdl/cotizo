import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../entity/share_data_orden.dart';
import '../services/my_get.dart';
import '../vars/my_paths.dart';
import 'avatar_logo.dart';
import 'my_infinity_list.dart';
import '../entity/orden_entity.dart';

class TileOrdenMrks extends StatelessWidget {

  final OrdenEntity item;
  final SharedDataOrden box;
  const TileOrdenMrks({
    Key? key,
    required this.item,
    required this.box,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(!Mget.isInit) {
      Mget.isInit = true;
      Mget.init(context, null);
      Mget.size = MediaQuery.of(context).size;
    }
    
    return FutureBuilder(
      future: _getDatos(),
      builder: (_, __) {

        return InkWell(
          onTap: () => _verPiezas(Mget.ctx),
          child: Container(
            width: Mget.size.width,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                AvatarLogo(logo: (box.marca == null) ? 'no-logo.png' : box.marca!.logo),
                const SizedBox(width: 10),
                Expanded(child: _tile())
              ],
            ),
          ),
        );
      },
    );
  }

  ///
  Widget _tile() {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Mget.size.width * 0.75,
            child: _titulo()
          ),
          const SizedBox(height: 3),
          Text(
            '???? SOLICITUDES DE COTIZACIÓN',
            textScaleFactor: 1,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: Mget.size.width,
            child: _pie(),
          )
        ],
      ),
    );
  }

  ///
  Widget _titulo() {

    var auto = 'AUTO DESCONOCIDO';
    if(box.marca != null) {
      auto = '${box.marca!.nombre} ${box.modelo!.nombre}';
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          auto,
          textScaleFactor: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF51a985)
          ),
          child: Text(
            '${item.piezas.length} ${ (item.piezas.length > 1) ? "Pzs" : "Pz"}.',
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    );
  }

  ///
  Widget _pie() {

    final fecha = '${item.createdAt.day}-${item.createdAt.month}-${item.createdAt.year}';

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'No. Orden:',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '${item.id}',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13
          ),
        ),
        const Spacer(),
        Text(
          'Publicado:',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11
          ),
        ),
        const SizedBox(width: 10),
        Text(
          fecha,
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11
          ),
        )
      ],
    );
  }

  ///
  void _verPiezas(BuildContext context) async {

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.black,
        contentPadding: const EdgeInsets.all(0),
        insetPadding: const EdgeInsets.all(0),
        scrollable: true,
        titlePadding: const EdgeInsets.all(0),
        buttonPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 90,
          child: const MyInfinityList(tile: 'gral')
        ),
      )
    );
  }

  ///
  Future<void> _getDatos() async {

    final em = box.solEm;
    if(box.auto == null) {
      // Iniciamos todas las cajas necesarias
      await box.solEm.initBoxes();
      box.auto = await em.getAutoById(item.auto);
      if(box.auto != null) {
        box.marca = await em.getMarcaById(box.auto!.marca);
        box.modelo = await em.getModeloById(box.auto!.modelo);
      }
    }
  }

}
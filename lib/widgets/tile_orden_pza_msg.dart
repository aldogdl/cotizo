import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../entity/pieza_entity.dart';
import '../entity/share_data_orden.dart';
import '../entity/orden_entity.dart';
import '../providers/gest_data_provider.dart';
import '../services/my_get.dart';
import '../services/my_paths.dart';

class TileOrdenPzaMsg extends StatelessWidget {

  final OrdenEntity item;
  final int idPza;
  final SharedDataOrden box;
  const TileOrdenPzaMsg({
    Key? key,
    required this.item,
    required this.idPza,
    required this.box,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, context.read<GestDataProvider>());
    
    return FutureBuilder(
      future: _getData(),
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {

          return InkWell(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(Mget.ctx!).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _dataOrd()
                      ),
                      _foto()
                    ],
                  ),
                  Divider(color: Colors.white.withOpacity(0.3)),
                  _pzasAndId()
                ],
              )
            ),
          );
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.065,
          child: const Center(
            child: SizedBox()
          )
        );
      },
    );
  }

  ///
  Widget _foto() {

    return CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 22,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: MyPath.getUriFotoPieza(item.fotos[item.piezas.first.id]![0]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  ///
  Widget _dataOrd() {

    String pieza = 'SIN NOMBRE';
    final p = item.piezas.firstWhere((p) => p.id == idPza, orElse: () => PiezaEntity());
    if(p.id != 0) {
      pieza = p.piezaName;
    }
    String pos = p.posicion;
    if(pos.length > 3) {
      pos = p.posicion.substring(0, 3);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '$pieza ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17
            ),
            children: [
              TextSpan(
                text: ' ${p.lado} $pos.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12
                ),
              )
            ],
          ),
          textScaleFactor: 1,
        ),
        const SizedBox(height: 5),
        Text(
          '${box.modelo!.nombre} ${box.auto!.anio} -> ${(box.auto!.isNac) ? "NACIONAL" : "IMPORTADO"}',
          textScaleFactor: 1,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 14
          ),
        ),
      ],
    );

  }

  ///
  Widget _pzasAndId() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Ord No.: ${item.id}',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Pza Id: $idPza',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14
          ),
        ),
        const Spacer(),
        Text(
          'Marca: ${box.marca!.nombre}',
          textScaleFactor: 1,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 14
          ),
        ),
      ],
    );
  }
  
  ///
  Future<void> _getData() async {

    box.auto = await box.solEm.getAutoById(item.auto);
    if(box.auto != null) {
      box.marca = await box.solEm.getMarcaById(box.auto!.marca);
      box.modelo = await box.solEm.getModeloById(box.auto!.modelo);
    }
  }
}
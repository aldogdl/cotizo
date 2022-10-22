import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../entity/share_data_orden.dart';
import '../entity/orden_entity.dart';
import '../providers/gest_data_provider.dart';
import '../services/my_get.dart';
import '../services/my_paths.dart';

class TileOrdenSoli extends StatelessWidget {

  final OrdenEntity item;
  final SharedDataOrden box;
  final bool withRouting;
  const TileOrdenSoli({
    Key? key,
    required this.item,
    required this.box,
    this.withRouting = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, context.read<GestDataProvider>());
    
    return FutureBuilder(
      future: _getData(),
      builder: (_, AsyncSnapshot snap) {

        if(snap.connectionState == ConnectionState.done) {

          return InkWell(
            onTap: () {
              if(withRouting) {
                context.go('/cotizo/${item.id}');
              }
            },
            child: Container(
              width: MediaQuery.of(Mget.ctx!).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _foto(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _dataOrd()
                    ),
                  ),
                  _pzasAndId()
                ],
              ),
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

    if(item.fotos[item.piezas.first.id]!.isEmpty) {
      return const SizedBox(
        child: Icon(Icons.no_photography_outlined, size: 40, color: Colors.grey)
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 25,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${box.modelo!.nombre} ${box.auto!.anio}',
          textScaleFactor: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${box.marca!.nombre} -> ${(box.auto!.isNac) ? "NACIONAL" : "IMPORTADO"}',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14
          ),
        ),
      ],
    );

  }

  ///
  Widget _pzasAndId() {

    final sufix = (item.piezas.length > 1) ? 'Pzas.' : 'Pza.';

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF51a985)
              ),
              child: Text(
                '${item.piezas.length}',
                textScaleFactor: 1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(width: 3),
            Text(
              sufix,
              textScaleFactor: 1,
              style: const TextStyle(
                color: Color(0xFF51a985),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'ID: ${item.id}',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
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
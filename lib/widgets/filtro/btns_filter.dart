import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'tile_filter.dart';
import '../../providers/ordenes_provider.dart';
import '../../vars/globals.dart';

class BtnsFilter extends StatelessWidget {

  final double altoFilters;
  final ValueChanged<String> onPress;
  const BtnsFilter({
    Key? key,
    required this.altoFilters,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final globals = Globals();
    final ordProv = context.read<OrdenesProvider>();

    return SizedBox(
      height: altoFilters, width: MediaQuery.of(context).size.width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: BoxDecoration(
          color: globals.bgAppBar,
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, -3),
              blurRadius: 8,
              spreadRadius: 1
            )
          ],
          border: const Border(
            top: BorderSide(color: Color.fromARGB(255, 73, 73, 73))
          )
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            TileFilter(
              filtro: 'Marcas', ico: Icons.minor_crash,
              altoFilters: altoFilters, onPress: (sel) => onPress(sel)
            ),
            TileFilter(
              filtro: 'Modelos', ico: Icons.time_to_leave_rounded,
              altoFilters: altoFilters, onPress: (sel) => onPress(sel)
            ),
            TileFilter(
              filtro: 'Ordenes', ico: Icons.discount,
              altoFilters: altoFilters, onPress: (sel) => onPress(sel)
            ),
            Selector<OrdenesProvider, int>(
              selector: (_, prov) => prov.pressBackDevice,
              builder: (_, press, __) {

                if(press != ordProv.oldValBackDevice) {
                  ordProv.oldValBackDevice = press;
                  Future.microtask(() => onPress('todas'));
                }

                return TileFilter(
                  filtro: 'Todas', ico: Icons.cleaning_services_rounded,
                  altoFilters: altoFilters, onPress: (sel) => onPress(sel)
                );
              },
            )
          ],
        )
      )
    );
  }
}
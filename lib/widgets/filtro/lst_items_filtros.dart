import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../filtrado_por_sols.dart';
import 'btns_filter.dart';
import '../filtrado_por_mds.dart';
import '../filtrado_por_mrks.dart';
import '../../providers/ordenes_provider.dart';

class LstItemsFiltros extends StatelessWidget {

  final double altoFilters;
  final String select;
  final ValueChanged<void> onSelect;
  const LstItemsFiltros({
    Key? key,
    required this.altoFilters,
    required this.select,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final ord = context.read<OrdenesProvider>();

    return SafeArea(
      child: StatefulBuilder(
        builder: (_, setState) {

          late Widget widgetFiltro;

          if(ord.typeFilter['from'] == 'none') {
            ord.typeFilter['select'] = select;
          }

          switch (ord.typeFilter['select']) {
            case 'marcas':
              widgetFiltro = FiltradoPorMrks(onPress: (_) => onSelect(_));
              break;
            case 'modelos':
              widgetFiltro = FiltradoPorMds(onPress: (_) => onSelect(_));
              break;
            case 'ordenes':
              widgetFiltro = FiltradoPorSols(onPress: (_) => onSelect(_));
              break;
            default:
              widgetFiltro = const SizedBox();
          }
          
          return Column(
            children: [
              BtnsFilter(
                altoFilters: altoFilters,
                onPress: (res){

                  if(res == 'todas') {
                    Future.microtask((){
                      ord.typeFilterClean();
                      Navigator.of(context).pop();
                    });
                    return;
                  }
                  
                  ord.typeFilter['from'] = 'modal';
                  ord.typeFilter['select'] = res;
                  setState((){});
                }
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: widgetFiltro,
                )
              )
            ],
          );
        },
      ),
    );
  }
}
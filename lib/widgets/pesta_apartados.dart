import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ordenes_provider.dart';

class PestaApartados extends StatefulWidget {

  final String tab;
  final ValueChanged<int> onAnimate;
  const PestaApartados({
    Key? key,
    required this.tab,
    required this.onAnimate,
  }) : super(key: key);

  @override
  State<PestaApartados> createState() => _PestaApartadosState();
}

class _PestaApartadosState extends State<PestaApartados> {

  /// Usado para saber si se agrego una pieza nueva al apartados
  Color bgInd = Colors.black;
  Color txInd = Colors.black;

  @override
  void initState() {
    bgInd = const Color.fromARGB(255, 235, 137, 80);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Selector<OrdenesProvider, int>(
          selector: (_, prov) => prov.cantApartados,
          builder: (cntx, val, child) {

            final orP = cntx.read<OrdenesProvider>();
            if(val > 0) {

              bool blockNav = orP.initApp;
              Future.delayed(const Duration(milliseconds: 250), (){
                if(mounted) {
                  if(orP.currentSeccion == 'apartados'){ blockNav = false; }
                  if(!blockNav){ widget.onAnimate(2); }
                }
              });
            }
            
            double hp = (val) > 9 ? 2 : 4.0;
            bgInd = (bgInd ==  const Color.fromARGB(255, 235, 137, 80))
              ? const Color.fromARGB(255, 11, 199, 73) : const Color.fromARGB(255, 235, 137, 80);
            txInd = (bgInd ==  const Color.fromARGB(255, 235, 137, 80))
              ? Colors.white : Colors.black;

            return (val > 0)
              ? Container(
                height: 17,
                padding: EdgeInsets.symmetric(
                  vertical: 2, horizontal: hp
                ),
                decoration: BoxDecoration(
                  color: bgInd,
                  borderRadius: BorderRadius.circular(17)
                ),
                child: Center(
                  child: Text(
                    (val > 9) ? '9+' : '$val',
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: txInd,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              )
              : const SizedBox(width: 0);
          },
        ),
        const SizedBox(width: 3),
        Text(
          widget.tab,
          textScaleFactor: 1,
          style: const TextStyle(
            fontSize: 15,
          ),
        )
      ],
    );
  }
}
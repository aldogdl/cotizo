import 'package:cotizo/vars/globals.dart';
import 'package:flutter/material.dart';

class FiltrarDialog extends StatelessWidget {

  final ValueChanged<String> onPresed;
  final String from;
  const FiltrarDialog({
    Key? key,
    required this.onPresed,
    required this.from
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return IconButton(
      onPressed: () => _dialogFiltrar(context),
      icon: const Icon(Icons.filter_list, color: Colors.white)
    );
  }

  ///
  Future<void> _dialogFiltrar(BuildContext context) async {

    final globals = Globals();

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => AlertDialog(        
        backgroundColor: globals.secMain,
        contentPadding: const EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tituDialog(
              context,
              Icons.filter_alt,
              'FILTRAR ${from == 'inv' ? "RESULTADOS:" : "SOLICITUDES:"}'
            ),
            _filtrarPorMenu(),
          ],
        )
      )
    );
  }

  ///
  Widget _tituDialog(BuildContext context, IconData ico, String titulo) {

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 81, 169, 133)
      ),
      child: Row(
        children: [
          Icon(ico, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            titulo,
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            )
          )
        ],
      )
    );
  }

  ///
  Widget _filtrarPorMenu() {

    List<Widget> items = [];
    const sp = SizedBox(height: 8);
    if(from == 'inv') {
      items = [
        sp,
        _txtIco(ico: Icons.directions_car_filled, label: 'POR MODELOS', fnc: 'modelos'),
        _txtIco(ico: Icons.abc, label: 'POR MARCAS', fnc: 'marcas'),
        _txtIco(ico: Icons.filter_alt_off, label: 'MOSTRAR TODOS', fnc: 'all'),
        sp
      ];
    }else{
      items = [
        sp,
        _txtIco(ico: Icons.abc, label: 'POR MARCAS', fnc: 'marcas'),
        _txtIco(ico: Icons.directions_car_filled, label: 'POR MODELOS', fnc: 'modelos'),
        _txtIco(ico: Icons.source_rounded, label: 'POR COTIZACIONES', fnc: 'cotizaciones'),
        sp
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  ///
  Widget _txtIco({
    required IconData ico,
    required String label,
    required String fnc}) 
  {

    return TextButton.icon(
      onPressed: () async => onPresed(fnc),
      icon: Icon(ico, color: const Color.fromARGB(255, 81, 169, 133)),
      label: Row(
        children: [
          Text(
            label.toUpperCase(),
            textScaleFactor: 1,
            style: const TextStyle(
              fontSize: 18, color: Color.fromARGB(255, 189, 189, 189),
              fontWeight: FontWeight.normal
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(
              Icons.arrow_forward_ios_rounded, size: 15, color: Colors.grey,
            )
          )
        ],
      )
    );
  }

}
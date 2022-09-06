import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyListIndicator extends StatelessWidget {

  final String error;
  final ValueChanged<void>? onTray;
  const EmptyListIndicator({
    Key? key,
    this.error = '',
    this.onTray,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: Opacity(
              opacity: 0.3,
              child: SvgPicture.asset(
                'assets/svgs/no_data.svg',
                fit: BoxFit.contain,
              ),
            )
          ),
          if(error.isEmpty)
            _sinDatos()
          else
            _excepcion()
        ],
      ),
    );
  }

  ///
  Widget _sinDatos() {

    return Column(
      children: const [
         Text(
          'SIN SOLICITUDES POR EL MOMENTO',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green
          )
        ),
        SizedBox(height: 5),
        Text(
          'ESTAMOS TRABAJANDO PARA TI...',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color.fromARGB(255, 202, 202, 202)
          )
        ),
        SizedBox(height: 5),
        Text(
          'Estate al pendiente, cientos de clientes esperan tus Autopartes, nosotros los estamos buscando.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: Colors.grey
          )
        )
      ],
    );
  }

  ///
  Widget _excepcion() {

    return Column(
      children: [
         const Text(
          'LA LISTA SE ENCONTRÓ VACIA',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green
          )
        ),
        const SizedBox(height: 5),
        const Text(
          '¿DESEAS INTENTARLO NUEVAMENTE?',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color.fromARGB(255, 202, 202, 202)
          )
        ),
        const SizedBox(height: 5),
        Text(
          getMsg(),
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w300,
            color: Colors.grey
          )
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.refresh),
          onPressed: () => onTray!(null),
          label: const Text(
            'INTENTAR DE NUEVO',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black
            )
          ),
        )
      ],
    );
  }

  ///
  String getMsg() {

    if(error.contains('null')) {
      return 'No se encontraron valores a mostrar';
    }
    if(error.contains('bad state')) {
      return 'Sin solicitudes para mostrar';
    }
    return error;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyListIndicator extends StatelessWidget {

  const EmptyListIndicator({Key? key}) : super(key: key);

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
          const Text(
            'SIN SOLICITUDES POR EL MOMENTO',
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
            'ESTAMOS TRABAJANDO PARA TI...',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 202, 202, 202)
            )
          ),
          const SizedBox(height: 5),
          const Text(
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
      ),
    );
  }
}
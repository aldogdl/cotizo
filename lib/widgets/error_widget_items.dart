import 'package:flutter/material.dart';

class ErrorWidgetItems extends StatelessWidget {

  final ValueChanged<void> onTryAgain;
  final String error;
  const ErrorWidgetItems({
    Key? key,
    required this.onTryAgain,
    required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: BoxConstraints.expand(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.warning_amber, color: Colors.amber, size: 150),
          const SizedBox(height: 20),
          Text(
            getMsg(),
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            )
          )
        ],
      )
    );
  }

  ///
  String getMsg() {

    if(error.contains('null')) {
      return 'No se encontraron valores a mostrar';
    }
    return error;
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/gest_data_provider.dart';

class BtnTake extends StatelessWidget {

  final ValueChanged<void> onPressed;
  const BtnTake({
    Key? key,
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    double tamI= 40.0;
    double tam = 48.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: tam, height: tam,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(100)
          ),
          child: Selector<GestDataProvider, bool>(
            selector: (_, prov) => prov.isTakeFoto,
            builder: (_, isTake, child) {

              if(isTake) { return child!; }

              return IconButton(
                onPressed: () {
                  context.read<GestDataProvider>().isTakeFoto = true;
                  onPressed(null);
                },
                padding: const EdgeInsets.all(0),
                constraints: BoxConstraints(
                  maxHeight: tamI, maxWidth: tamI,
                  minHeight: tamI, minWidth: tamI
                ),
                iconSize: tamI,
                alignment: Alignment.center,
                color: Colors.white,
                icon: const Icon(Icons.circle)
              );
            },
            child: SizedBox(
              width: tamI, height: tamI,
              child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.blue),
            ),
          )
        )
      ],
    );
  }
}
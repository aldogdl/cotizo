import 'package:flutter/material.dart';

class Cargando extends StatelessWidget {

  final double w;
  final double h;
  const Cargando({
    Key? key,
    this.w = 0, this.h = 0
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(20),
      width: (w != 0) ? w : MediaQuery.of(context).size.width,
      height: (h != 0) ? h : MediaQuery.of(context).size.height,
      child: const Center(
        child: SizedBox(
          height: 60, width: 60,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}
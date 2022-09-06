import 'package:flutter/material.dart';

import '../config/sngs_manager.dart';
import '../vars/globals.dart';

class CounterLoad extends StatefulWidget {

  const CounterLoad({Key? key}) : super(key: key);

  @override
  State<CounterLoad> createState() => _CounterLoadState();
}

class _CounterLoadState extends State<CounterLoad> {

  final _globals = getIt<Globals>();
  late Size size;
  final double circle = 0.6;

  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * circle,
      height: size.width * circle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: _circle(
              scale: circle,
              isTap: false,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFb0fdd2),
                  Color(0xFF6de13b),
                  Color(0xFF123104),
                  Color(0xFF12310a),
                ]
              )
            )
          ),
          _circle(scale: 0.02),
          _mediaLuna(radians: -1, scale: 0.04),
          _circle(scale: 0.05),
          _circleTexture(scale: 0.1),
          Container(
            width: size.width * (circle - 0.10),
            height: size.width * (circle - 0.10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size.width),
              gradient: const RadialGradient(
                colors: [
                  Colors.black,
                  Colors.black,
                  Colors.transparent
                ]
              )
            ),
          ),
          _circle(scale: 0.2),
          SizedBox(
            width: size.width * 0.43,
            height: size.width * 0.43,
            child: const CircularProgressIndicator(),
          ),
          _mediaLuna(radians: 1.9, scale: 0.25),
          _circle(scale: 0.3),
          _numeral()
        ],
      ),
    );
  }

  ///
  Widget _numeral() {

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StreamBuilder<String>(
          stream: _getSeconds(),
          initialData: '1',
          builder: (_, AsyncSnapshot snap) {
            return Text(
              snap.data,
              textScaleFactor: 1,
              style: const TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            );
          },
        ),
        StreamBuilder<String>(
          stream: _getMicro(),
          initialData: '1',
          builder: (_, AsyncSnapshot snap) {

            return Text(
              snap.data,
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold
              ),
            );
          },
        )
      ],
    );
  }
  ///
  Widget _mediaLuna({
    required double scale,
    required double radians,
  }) {

    return _circle(
      scale: scale,
      isTap: false,
      gradient: LinearGradient(
        colors: [
          const Color(0xFF6de13b),
          _globals.bgMain,
          _globals.bgMain,
        ],
        transform: GradientRotation(radians)
      )
    );
  }

  ///
  Widget _circleTexture({
    required double scale,
  }) {

    return Container(
      width: size.width * (circle - scale),
      height: size.width * (circle - scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_text.png'),
          fit: BoxFit.cover
        )
      ),
    );
  }

  ///
  Widget _circle({
    required double scale,
    Gradient? gradient,
    bool isTap = true
  }) {

    Color? color = (isTap) ? _globals.bgMain : null;

    return Container(
      width: size.width * (circle - scale),
      height: size.width * (circle - scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width),
        color: color,
        gradient: gradient
      ),
    );
  }

  ///
  Stream<String> _getSeconds() async* {

    for (var i = 1;;) {
      if(i == 60) {
        i = 1;
      }
      yield '${i++}'.padLeft(2, '0');
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  ///
  Stream<String> _getMicro() async* {

    for (var i = 1;;) {
      if(i >= 10000) {
        i = 1;
      }
      yield '${i++}'.padLeft(5, '0');
      await Future.delayed(const Duration(microseconds: 1000));
    }
  }

}
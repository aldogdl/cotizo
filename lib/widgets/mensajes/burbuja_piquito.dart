
import 'package:flutter/material.dart';

import '../../vars/enums.dart';

class BurbujaPiquito extends CustomPainter {

  final Color bg;
  final ChatFrom from;
  BurbujaPiquito({required this.bg, required this.from});

  @override
  void paint(Canvas canvas, Size size) {
    
    Paint paint = Paint();
    Path path = Path();
    paint.color = bg;
    path.moveTo(0, 0);
    if(from == ChatFrom.anet) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }else{
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }
    path.close();

    return canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}
import 'package:flutter/material.dart';

class BGImgPzas extends StatelessWidget {

  final Color bgColor;
  final Widget child;
  const BGImgPzas({
    Key? key,
    required this.bgColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/bg.jpg'),
          repeat: ImageRepeat.repeat,
          fit: BoxFit.none,
          invertColors: true,
          colorFilter: ColorFilter.mode(bgColor, BlendMode.dst)
        )
      ),
      child: child
    );
  }
}
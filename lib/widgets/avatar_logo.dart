import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../vars/my_paths.dart';

class AvatarLogo extends StatelessWidget {

  final String logo;
  const AvatarLogo({
    Key? key,
    required this.logo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 25,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 23,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: MyPath.getUriLogoMrk(logo),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../entity/orden_entity.dart';

class TileOrdenSoli extends StatelessWidget {

  final OrdenEntity item;
  const TileOrdenSoli({
    Key? key,
    required this.item
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> marcas = [
      {'m':'FORD', 'md':'MUSTANG', 'a': '2009', 'n':'IMPORTADO'},
      {'m':'FORD', 'md':'MUSTANG', 'a': '2009', 'n':'IMPORTADO'},
      {'m':'FORD', 'md':'MUSTANG', 'a': '2009', 'n':'IMPORTADO'},
      {'m':'FORD', 'md':'MUSTANG', 'a': '2009', 'n':'IMPORTADO'},
      {'m':'FORD', 'md':'MUSTANG', 'a': '2009', 'n':'IMPORTADO'},
      {'m':'FORD', 'md':'MUSTANG', 'a': '2009', 'n':'IMPORTADO'},
    ];

    List<String> pzas = [
      'https://peru21.pe/resizer/gf4thh61l3hOI_byR5Pmuk10KhU=/580x330/smart/filters:format(jpeg):quality(75)/arc-anglerfish-arc2-prod-elcomercio.s3.amazonaws.com/public/JHX7MNYQYNEX5LRW4IV5CZVO4Q.jpg',
      'https://memolira.com/wp-content/uploads/2021/05/auto-chatarra-autopartes-3.jpg',
      'https://i.ebayimg.com/images/g/8HgAAOSwmdtd0us8/s-l800.jpg',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8Lx1zzdp8EMKBAa9QvQSf3qGoTQU7iLQoGQ&usqp=CAU',
      'https://images.segundamano.mx/api/v1/smmx/images/36/3616539934.jpg?rule=web_gallery_3x',
      'https://images.segundamano.mx/api/v1/smmx/images/17/1736608011.jpg?rule=web_gallery_3x',
    ];

    final rnd = Random();
    final ind = rnd.nextInt(pzas.length);
    const idT1 = 0;

    return InkWell(
      onTap: () => context.go('/cotizo/${item.id}-$idT1-$idT1-$idT1/'),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 25,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: pzas[ind],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${marcas[ind]['md']} - ${marcas[ind]['a']}',
                          textScaleFactor: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF51a985)
                              ),
                              child: Text(
                                '${rnd.nextInt(10)}',
                                textScaleFactor: 1,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Pzas.',
                              textScaleFactor: 1,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${marcas[ind]['m']} - ${marcas[ind]['n']}',
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 17
                          ),
                        ),
                        Text(
                          'ID: 2536',
                          textScaleFactor: 1,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
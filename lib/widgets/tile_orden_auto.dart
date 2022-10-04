import 'package:flutter/material.dart';

import '../services/my_get.dart';

class TileOrdenAuto extends StatelessWidget {

  final Map<String, dynamic> item;
  final String tipo;
  final ValueChanged<Map<String, dynamic>> onPress;
  const TileOrdenAuto({
    Key? key,
    required this.item,
    required this.tipo,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Mget.init(context, null);
    if(!Mget.isInit) {
      Mget.isInit = true;
      Mget.size = MediaQuery.of(context).size;
    }

    return InkWell(
      onTap: () => onPress(item),
      child: Container(
        width: Mget.size.width,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: 45, height: 45,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color.fromARGB(255, 83, 83, 83)
              ),
              child: Center(
                child: Text(
                  _getInitialMrk(item['marca']),
                  textScaleFactor: 1,
                  style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 51, 51, 51)
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _tile())
          ],
        ),
      ),
    );
  }

  ///
  Widget _tile() {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Mget.size.width * 0.75,
            child: _titulo()
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: Mget.size.width,
            child: _pie(),
          )
        ],
      ),
    );
  }

  ///
  Widget _titulo() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text.rich(
          TextSpan(
            text: (tipo == 'mrk') ? '${item['marca']}  ' : '${item['modelo']}  ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17
            ),
            children: [
              TextSpan(
                text: (item['isNac']) ? 'NACIONAL' : 'IMPORTADO',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14
                ),
              ),
            ],
          ),
          textScaleFactor: 1,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF51a985)
          ),
          child: Text(
            '${item['cPzas']} ${ (item['cPzas'] > 1) ? "Pzs" : "Pz"}.',
            textScaleFactor: 1,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    );
  }

  ///
  Widget _pie() {

    final create = item['created'];

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Cant. de Solicitudes:',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '${item['ords'].length}',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13
          ),
        ),
        const Spacer(),
        Text(
          'Publicado:',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${create.day}/${create.month}/${create.year}',
          textScaleFactor: 1,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11
          ),
        )
      ],
    );
  }

  ///
  String _getInitialMrk(String marca) => marca.substring(0, 1);
}
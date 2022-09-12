import 'package:flutter/material.dart';

import '../repository/inventario_repository.dart';

class CuotasStorage extends StatefulWidget {

  const CuotasStorage({Key? key}) : super(key: key);

  @override
  State<CuotasStorage> createState() => _CuotasStorageState();
}

class _CuotasStorageState extends State<CuotasStorage> {

  final _invEm  = InventarioRepository();
  Map<String, dynamic> _info = {};

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _infoAlmacenamiento()
    );
  }

  ///
  Widget _infoAlmacenamiento() {

    const sp = SizedBox(height: 10);
    return FutureBuilder(
      future: _getInfo(),
      builder: (_, AsyncSnapshot snap) {
        
        if(snap.connectionState == ConnectionState.done) {

          return Column(
            children: [
              _txtRow('total de piezas', _info['pzs']),
              sp,
              _txtRow('total de fotos', _info['fts']),
              sp,
              _txtRow('disco', '${_info['kb']} kbs.'),
              sp,
              _txtRow('almacenamiento', '${_info['mg']} Mgs.'),
              sp,
              const Divider(color: Colors.grey),
              _status(),
              const Divider(color: Colors.grey),
            ],
          );
        }
        
        return _load();
      },
    );
  }

  ///
  Widget _load() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ///
  Widget _status() {

    const int tt = 250;
    double mgs = double.parse(_info['mg']);

    return Row(
      children: [
        _text('0', fs: 12),
        const SizedBox(width: 5),
        Expanded(
          child: LayoutBuilder(
            builder: (_, restrics) {

              double x = (mgs * restrics.maxWidth) / tt;
              final libres = tt - mgs;
              if(x < 1) { x = 10; }
              if(libres == tt) { x = 0; }

              return Container(
                constraints: BoxConstraints.expand(
                  width: restrics.maxWidth,
                  height: 20
                ),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      color: Colors.blueGrey,
                    ),
                    Container(
                      width: x,
                      color: Colors.green,
                    ),
                    Center(
                      child: _text(
                        'Libres: ${libres.toStringAsFixed(2)} Mgs.',
                        fs: 12,
                        cl: Colors.black
                      ),
                    )
                  ],
                )
              );
            },
          ),
        ),
        const SizedBox(width: 5),
        _text('$tt',fs: 12),
      ],
    );
  }

  ///
  Widget _txtRow(String label, String value) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _text(label, fs: 14, cl: Colors.grey),
        _text(value, fs: 14, cl: Colors.white),
      ],
    );
  }

  ///
  Widget _text(String label, {double fs = 18, Color cl = Colors.green, bool ib = false}) {

    return Text(
      label.toUpperCase(),
      textScaleFactor: 1,
      style: TextStyle(
        fontSize: fs, color: cl,
        fontWeight: (ib) ? FontWeight.bold : FontWeight.normal
      ),
    );
  }

    ///
  Future<void> _getInfo() async {

    if(_info.isEmpty) {
      _info = await _invEm.getInfo();
    }
  }
}
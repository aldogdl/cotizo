import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:provider/provider.dart';

import '../../providers/gest_data_provider.dart';

class TileFotoThubm extends StatefulWidget {

  final DeviceOrientation orientation;
  final ValueChanged<void> onView;
  final String foto;
  const TileFotoThubm({
    Key? key,
    required this.orientation,
    required this.foto,
    required this.onView,
  }) : super(key: key);

  @override
  State<TileFotoThubm> createState() => _TileFotoThubmState();
}

class _TileFotoThubmState extends State<TileFotoThubm> {

  late GestDataProvider _provG;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {
    
    double w = 90.0;
    double h = (768 * w) / 1024;

    if(!_isInit) {
      _isInit = true;
      _provG = context.read<GestDataProvider>();
    }
    int rotate = 0;
    if(widget.orientation == DeviceOrientation.landscapeLeft) {
      rotate = 1;
    }
    if(widget.orientation == DeviceOrientation.landscapeRight) {
      rotate = -1;
    }
    return RotatedBox(
      quarterTurns: rotate,
      child: Container(
        width: w, height: h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white.withOpacity(0.1),
        ),
        child: _body(),
      ),
    );
  }

  ///
  Widget _body() {

    if(widget.foto == '0') {

      return Center(
        child: Icon(
          Icons.photo_camera_back,
          color: Colors.grey.withOpacity(0.2),
          size: 35,
        ),
      );
    }
    
    bool isSelect = false;
    final idx = _provG.ftsGest.indexWhere((e) => e.path == widget.foto);
    if(idx != -1) {
      isSelect = _provG.ftsGestDel.contains(idx) ? true : false;
    }

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        InkWell(
          onLongPress: () => _selectImgForDelete(isSelect),
          onTap: () {
            if(_provG.ftsGestDel.isNotEmpty) {
              if(_provG.ftsGestDel.first != -1) {
                _selectImgForDelete(isSelect);
              }
            }else{
              widget.onView(null);
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              alignment: Alignment.center,
              File(widget.foto),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if(isSelect)
          _selectImg()
      ],
    );
  }

  ///
  Widget _selectImg() {

    return Positioned(
      top: 3, right: 3,
      child: Container(
        width: 23, height: 23,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
          color: Colors.black
        ),
        child: const Icon(Icons.check_circle_rounded, color: Colors.orange, size: 20),
      ),
    );
  }

  ///
  void _selectImgForDelete(bool isSelect) {
    _provG.addFtoToDelete(widget.foto, !isSelect);
    setState(() {});
  }
}
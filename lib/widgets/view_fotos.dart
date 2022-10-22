import 'dart:io';
import 'package:cotizo/config/sngs_manager.dart';
import 'package:cotizo/services/my_image/my_im.dart';
import 'package:cotizo/services/my_paths.dart';
import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';

import '../vars/globals.dart';

class ViewFotos extends StatefulWidget {

  final List<String> fotosList;
  final String bySrc;
  final int jumpTo;
  final ValueChanged<List<int>>? onDelete;
  final ValueChanged<void>? onClose;
  const ViewFotos({
    Key? key,
    required this.fotosList,
    this.jumpTo = 0,
    this.bySrc = 'network',
    this.onDelete,
    this.onClose
  }) : super(key: key);

  @override
  State<ViewFotos> createState() => _ViewFotosState();
}

class _ViewFotosState extends State<ViewFotos> {

  final ExtendedPageController _ctrPage = ExtendedPageController();
  final _globals = getIt<Globals>();

  int currentIndex = 0;
  List<String> fotos = [];
  List<int> fotosDel = [];

  @override
  void initState() {

    fotos = List<String>.from(widget.fotosList);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      if(widget.jumpTo > 0) {
        currentIndex = widget.jumpTo;
        _ctrPage.animateToPage(
          currentIndex,
          duration: const Duration(microseconds: 350),
          curve: Curves.easeIn
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _ctrPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () {
        if(widget.onClose != null) {
          widget.onClose!(null);
        }
        return Future.value(true);
      },
      child: Column(
        children: [
          Expanded(child: _viewer()),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(widget.bySrc != 'network')
                  _delete(currentIndex),
                const Spacer(),
                _flecha('back'),
                const SizedBox(width: 5),
                _txtGo('${currentIndex+1}'),
                _txtGo('  de  '),
                _txtGo('${fotos.length}'),
                const SizedBox(width: 5),
                _flecha('next'),
                const Spacer(),
                _close(),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///
  Widget _delete(int indexFoto) {

    bool active = (widget.bySrc == 'network') ? false : true;

    return IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        if(active) {
          if(fotosDel.contains(indexFoto)) {
            fotosDel.remove(indexFoto);
          }else{
            fotosDel.add(indexFoto);
          }
          widget.onDelete!(fotosDel);
          setState(() {});
        }
      },
      icon: Icon(
        (fotosDel.contains(indexFoto))
          ? Icons.delete_outline
          : Icons.delete_sharp,
        color: Colors.green.withOpacity(0.8), size: 35
      )
    );
  }

  ///
  Widget _close() {

    return IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        if(widget.onClose != null) {
          widget.onClose!(null);
        }
        Navigator.of(context).pop(false);
      },
      icon: Icon(
        Icons.close,
        color: Colors.green.withOpacity(0.8), size: 35
      )
    );
  }

  ///
  Widget _flecha(String donde) {

    const dur = Duration(milliseconds: 300);
    const cur = Curves.easeIn;

    return IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        if(donde == 'back') {
          _ctrPage.previousPage(duration: dur, curve: cur);
        }else{
          _ctrPage.nextPage(duration: dur, curve: cur);
        }
      },
      icon: Icon(
        (donde == 'back') ? Icons.arrow_circle_left_outlined : Icons.arrow_circle_right_outlined,
        color: Colors.green.withOpacity(0.8), size: 50
      )
    );
  }

  ///
  Widget _txtGo(String label) {

    return Text(
      label,
      textScaleFactor: 1,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14
      ),
    );
  }

  ///
  Widget _viewer() {

    return ExtendedImageGesturePageView.builder(
      itemCount: fotos.length,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (int index) {
        setState(() {
          currentIndex = index;
        });
      },
      controller: _ctrPage,
      scrollDirection: Axis.horizontal,
      itemBuilder: (_, int index) {

        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: (widget.bySrc == 'network')
              ? _byNetwork(index) : _byFilePath(index),
            ),
            if(fotosDel.contains(index))
              Positioned.fill(
                child: Center(
                  child: Icon(
                    Icons.delete_forever,
                    size: MediaQuery.of(context).size.width * 0.7,
                    color: Colors.red.withOpacity(0.2),
                  ).frosted(
                    blur: 2.5,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(8),
                  ),
                )
              )
          ],
        );
      }
    );
  }

  ///
  Widget _byFilePath(int index) {

    if(widget.bySrc == 'inventario') {

      return FutureBuilder(
        future: MyIm.getImageByPath(fotos[index]),
        builder: (_, AsyncSnapshot snap) {

          if(snap.connectionState == ConnectionState.done) {
            if(snap.hasData) {
              return _imgByFile(snap.data);
            }else{
              return Icon(Icons.photo_size_select_small_rounded, color: _globals.bgMain, size: 100);
            }
          }
          return const Center( child: CircularProgressIndicator() );
        },
      );
    }

    return _imgByFile(File(fotos[index]));
  }

  ///
  Widget _imgByFile(File file) {

    return ExtendedImage.file(
      file,
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      clearMemoryCacheWhenDispose: true,
      enableMemoryCache: true,
    );
  }

  ///
  Widget _byNetwork(int index) {

    return ExtendedImage.network(
      MyPath.getUriFotoPieza(fotos[index]),
      fit: BoxFit.contain,
      mode: ExtendedImageMode.gesture,
      clearMemoryCacheWhenDispose: true,
      enableMemoryCache: true,
    );
  }
}
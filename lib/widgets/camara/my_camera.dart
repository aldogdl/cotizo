import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:image/image.dart' as img;
import 'package:blur/blur.dart';

import '../show_dialogs.dart';
import '../../config/sngs_manager.dart';
import '../../providers/gest_data_provider.dart';
import '../../vars/globals.dart';
import '../../vars/constantes.dart';
import '../../vars/enums.dart';
import '../../widgets/view_fotos.dart';
import '../../widgets/camara/cargando.dart';
import '../../widgets/camara/portrait_cam.dart';

class MyCamera extends StatefulWidget {

  final ValueChanged<List<XFile>> onFinish;
  final ValueChanged<List<XFile>> fromGaleria;
  final bool isTest;
  const MyCamera({
    Key? key,
    required this.onFinish,
    required this.fromGaleria,
    this.isTest = false
  }) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> with WidgetsBindingObserver{

  final _globals = getIt<Globals>();
  final _errorCamera = ValueNotifier<String>('');
  final _currentZoomLevel = ValueNotifier<double>(1.0);
  final _isCameraInitialized = ValueNotifier<bool>(false);
  
  late final ValueNotifier<bool> _showMsg;
  late GestDataProvider _provG;

  DeviceOrientation _oriCurrent = DeviceOrientation.portraitUp;
  CameraController? _controller;
  bool _isInit = false;
  double _minAvailableZoom = 1.0;
  bool _showPrepareExit = false;
  // double _maxAvailableZoom = 1.0;

  @override
  void initState() {

    if(!widget.isTest) {
      _showMsg = ValueNotifier<bool>(false);
    }else{
      _showMsg = ValueNotifier<bool>(true);
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await onNewCameraSelected();
    });
  }

  @override
  void dispose() async {

    _controller?.dispose();
    _errorCamera.dispose();
    _currentZoomLevel.dispose();
    _isCameraInitialized.dispose();
    _showMsg.dispose();
    imageCache.clear();
    imageCache.clearLiveImages();
    PaintingBinding.instance.imageCache.clear();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      await onNewCameraSelected();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: _globals.bgMain,
      body: WillPopScope(
        onWillPop: () async {
          await _prepareExit();
          return Future.value(true);
        },
        child: SafeArea(
          child: (!_showPrepareExit) 
          ? NativeDeviceOrientedWidget(
              useSensor: true,
              portrait: (context) => _diseVertical(DeviceOrientation.portraitUp),
              portraitDown: (context) => _diseVertical(DeviceOrientation.portraitUp),
              portraitUp: (context) => _diseVertical(DeviceOrientation.portraitUp),
              landscapeLeft: (context) => _diseVertical(DeviceOrientation.landscapeLeft),
              landscape: (context) => _diseVertical(DeviceOrientation.landscapeLeft),
              landscapeRight: (context) => _diseVertical(DeviceOrientation.landscapeRight),
              fallback: (context) => _disUnknow(),
            )
          : Container(
            color: _globals.bgMain,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(child: Cargando()),
          )
        ),
      )
    );
  }

  ///
  Widget _disUnknow({String txt = 'Coloca tu Dispositivo en Posición Vertical'}) {
    
    return Center(
      child: Text(
        txt,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w200,
          color: Color(0xFFffffff)
        ),
      )
    );
  }

  ///
  Widget _diseVertical(DeviceOrientation orientation) {

    _oriCurrent = orientation;
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: LayoutBuilder(
            builder: (_, c) {

              return ValueListenableBuilder(
                valueListenable: _isCameraInitialized,
                builder: (_, isI, child) {

                  if(!isI) { return child!; }
                  return _laCamara();
                },
                child: Cargando(w: c.maxWidth, h: c.maxHeight),
              );
            },
          ),
        ),
        Expanded(
          child: PortraitCam(
            isTest: widget.isTest,
            orientation: orientation,
            fromGalery: (acc) async => await _prepareExit(isPressGalery: true),
            onClose: (_) async => await _prepareExit(),
            onPressed: (_) async => _takeFoto(),
            onConfirm: (_) async => _prepareExit(isConfirm: true),
            onView: (ft) async => _showVisor(ft)
          ),
        )
      ],
    );
  }

  ///
  Widget _laCamara() {

    double h = 0.0;
    double w = 0.0;
    if(MediaQuery.of(context).orientation.name == 'landscape') {
      w = (MediaQuery.of(context).size.width * 0.65);
      h = (768*w) / 1024;
    }else{
      double max = (MediaQuery.of(context).size.height * 0.65);
      h = max;
      w = MediaQuery.of(context).size.width;
      double anchoTmp = (768 * max)/1024;
      if(anchoTmp < w) {
        h = (1024*w)/768;
      }
    }

    return SizedBox(
      width: w, height: h,
      child: AspectRatio(
        aspectRatio: 1/_controller!.value.aspectRatio,
        child: LayoutBuilder(
          builder: (_, constraints) {

            return ValueListenableBuilder<bool>(
              valueListenable: _showMsg,
              builder: (_, show, child) {

                int time = 20000;
                if(_provG.modoCot == 3) {
                  time = 3000;
                }
                if(show) {
                  Future.delayed(Duration(milliseconds: time), (){
                    if(mounted) {
                      _showMsg.value = false;
                    }
                  });
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    child!,
                    if(show)
                      Positioned(
                        top: 0, left: 0, right: 0, bottom: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: _msgAddFotos(constraints),
                        ),
                      )
                  ],
                );
              },
              child: _camWidget(constraints),
            );
          },
        )
      ),
    );
  }

  ///
  Widget _camWidget(BoxConstraints constraints) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (detalles) {
        _onViewFinderTap(detalles, constraints);
      },
      child: _controller!.buildPreview()
    );
  }

  ///
  Future<void> _showVisor(int ft) async {

    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: _globals.bgMain,
      isScrollControlled: true,
      builder: (_) => ViewFotos(
        bySrc: 'cache',
        fotosList: _provG.ftsGest.map((e) => e.path).toList(),
        jumpTo: ft,
        onClose: (_){
          if(_provG.ftsGestDel.isNotEmpty) {
            _provG.deleteFotosSelected();
          }
        },
        onDelete: (ft){
          _provG.ftsGestDel = ft;
        },
      )
    );
  }

  ///
  Widget _msgAddFotos(BoxConstraints constraints) {

    String txt = 'Es recomendable que las fotos se tomen de manera horizontal '
    'para capturar más información gráfica de tus piezas.';
    
    return Container(
        width: constraints.maxWidth, height: constraints.maxHeight,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.camera, size: 150, color: Colors.grey,).frosted(
              frostColor: Colors.white,
              borderRadius: BorderRadius.circular(150),
              frostOpacity: 0
            ),
            const SizedBox(height: 20),
            const Text(
              'COLOQUEMOS FOTOS A TU COTIZACIÓN',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800
              ),
            ),
            const SizedBox(height: 30),
            Text(
              txt,
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: (){
                _showMsg.value = false;
              },
              child: const Text(
                'ENTENDIDO',
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                  fontWeight: FontWeight.w800
                ),
              ),
            )
          ],
        ),
      ).frosted(
        borderRadius: BorderRadius.circular(10)
      );
  }

  ///
  Future<void> _takeFoto() async {

    int fotosCurrent = List<XFile>.from(_provG.ftsGest).length;
    if(fotosCurrent >= Constantes.cantFotos) {
      await ShowDialogs.alert(
        context, 'fotosCantCam',
        hasActions: false
      );
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () async {

      XFile? xfile;
      try {
        xfile = await _controller!.takePicture();
      } catch (_) {
        _provG.isTakeFoto = false;
        return;
      }

      String path = xfile.path;
      if(fotosCurrent < Constantes.cantFotos) {

        if(_oriCurrent != DeviceOrientation.portraitUp) {

          img.Image? origin = img.decodeJpg(await xfile.readAsBytes());
          if(_oriCurrent == DeviceOrientation.landscapeLeft) {
            origin = img.copyRotate(origin!, -90);
          }
          if(_oriCurrent == DeviceOrientation.landscapeRight) {
            origin = img.copyRotate(origin!, 90);
          }

          File? file = File(xfile.path);
          file = await file.writeAsBytes(img.encodeJpg(origin!), flush: true );
          Uint8List? bytes = file.readAsBytesSync();
          xfile = XFile(path, bytes: bytes, length: bytes.length, name: xfile.name);
          file = null; bytes = null;
        }
        _provG.addNewFoto(xfile);
        xfile = null;
        _provG.isTakeFoto = false;
      }

    });
  }

  ///
  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    
    _controller!.setExposurePoint(offset);
    _controller!.setFocusPoint(offset);
  }

  ///
  Future<void> onNewCameraSelected() async {

    if(!_isInit) { _isInit = true; await _prepareInit(); }

    CameraController? previousCameraController = _controller;
    if(previousCameraController != null) {
      await previousCameraController.dispose();
    }

    // Initialize controller
    final CameraController cameraController = CameraController(
      _globals.firstCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController.initialize();
    } on CameraException catch (_) {
      _showErrInitCamera();
      return;
    }

    if(cameraController.value.isInitialized) {

      // _maxAvailableZoom = await cameraController.getMaxZoomLevel();
      _minAvailableZoom = await cameraController.getMinZoomLevel();
      _currentZoomLevel.value = _minAvailableZoom;
      await cameraController.setZoomLevel(_minAvailableZoom);
      await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _controller = cameraController;

      if (mounted) {
        _isCameraInitialized.value = _controller!.value.isInitialized;
        Future.delayed(const Duration(milliseconds: 250), () async {
          await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
            SystemUiOverlay.bottom
          ]);
        });
      }
    }
  }

  ///
  Future<void> _prepareInit() async {

    _provG = context.read<GestDataProvider>();
    
    if(_provG.campos.containsKey(Campos.rFotos)) {

      final fC = List<String>.from(_provG.campos[Campos.rFotos]);
      if(fC.isNotEmpty) {
        _provG.ftsGest.clear();
        for (var i = 0; i < fC.length; i++) {
          File f = File(fC[i]);
          if(f.existsSync()) {
            final bites = f.readAsBytesSync();
            _provG.ftsGest.add(
              XFile.fromData(
                bites, length: bites.length, path: f.path,
                name: f.path.split(Platform.pathSeparator).last,
              )
            );
          }
        }
      }
    }
  }

  ///
  Future<void> _prepareExit({bool isConfirm = false, bool isPressGalery = false}) async {

    if(widget.isTest) {
      await _provG.deleteFotosSelected(cleaned: true);
    }else{

      if(_provG.ftsGest.isNotEmpty) {
        // Si se quiere salir cancelando y no confirmando cambios, revisamos
        // si el usuario cuenta con fotos, si es asi, mostramos alerta.
        if(!isConfirm && !isPressGalery) {
          bool? res = await ShowDialogs.alert(
            context, 'fotosCantCamClose',
            hasActions: true,
            labelOk: 'SI, SALIR',
            labelNot: 'CANCELAR'
          );
          res = (res == null) ? false : res;
          if(!res){
            setState(() {
              _showPrepareExit = false;
            });
            return;
          }else{
            await _provG.deleteFotosSelected(cleaned: true);
          }
        }
      }
    }

    setState(() { _showPrepareExit = true; });
    await Future.delayed(const Duration(milliseconds: 250));
    await SystemChrome.restoreSystemUIOverlays();
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, overlays: [
        SystemUiOverlay.top, SystemUiOverlay.bottom
      ]
    );

    try {
      await _controller?.pausePreview();
      await _controller?.unlockCaptureOrientation();
      _controller?.removeListener(() { });
    } catch (_) {}
    
    if(_provG.isTakeFoto) {
      _provG.isTakeFoto = false;
    }

    if(isPressGalery) {
      widget.fromGaleria(_provG.ftsGest);
    }else{
      widget.onFinish(_provG.ftsGest);
    }

    _provG.ftsGest.clear();
    _provG.ftsGestDel.clear();
    _provG.showAlertAddFotos = false;
  }

  ///
  void _showErrInitCamera() async {

    await ShowDialogs.alert(
      context, 'errCam',
      hasActions: false
    ).then((_) => Navigator.of(context).pop());
  }


  /// No lo quite por que mas adelante puedo necesitar colocar zoom
  // Widget _controlesUi() {

  //   return Container(
  //     color: Colors.black,
  //     constraints: const BoxConstraints.expand(),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         const Spacer(),
  //         _btnCircle(icono: Icons.arrow_circle_up, fnc: () async {
  //           if(_currentZoomLevel.value > _minAvailableZoom) {
  //             _currentZoomLevel.value--;
  //             await _controller!.setZoomLevel(_currentZoomLevel.value);
  //           }
  //         }),
  //         const SizedBox(height: 10),
  //         _indicatorBy(
  //           ValueListenableBuilder<double>(
  //             valueListenable: _currentZoomLevel,
  //             builder: (_, txtV, __) => Text(
  //               '${txtV.toStringAsFixed(1)}x',
  //               textScaleFactor: 1,
  //               style: TextStyle(color: _globals.bgMain),
  //             ),
  //           )
  //         ),
  //         const SizedBox(height: 10),
  //         _btnCircle(icono: Icons.arrow_circle_down, fnc: () async {
  //           if(_currentZoomLevel.value < _maxAvailableZoom) {
  //             _currentZoomLevel.value++;
  //             await _controller!.setZoomLevel(_currentZoomLevel.value);
  //           }
  //         }),
  //       ],
  //     ),
  //   );
  // }

  // ///
  // Widget _btnCircle({
  //   required IconData icono, required Function fnc}) 
  // {

  //   return CircleAvatar(
  //     radius: 26,
  //     backgroundColor: _globals.secMain,
  //     child: IconButton(
  //       onPressed: () => fnc(),
  //       icon: Icon(icono),
  //       iconSize: 40,
  //       color: _globals.txtOnsecMainDark,
  //       padding: const EdgeInsets.all(0),
  //       visualDensity: VisualDensity.compact,
  //     )
  //   );
  // }

  // ///
  // Widget _indicatorBy(Widget child) {

  //   return RotatedBox(
  //     quarterTurns: 0,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: _globals.colorGreen,
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: child
  //       ),
  //     ),
  //   );
  // }

}
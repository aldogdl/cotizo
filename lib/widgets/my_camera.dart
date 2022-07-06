import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import '../widgets/help_icons_camera.dart';
import '../config/sngs_manager.dart';
import '../providers/gest_data_provider.dart';
import 'show_dialogs.dart';
import '../vars/enums.dart';
import '../vars/globals.dart';
import '../vars/constantes.dart';

class MyCamera extends StatefulWidget {

  final ValueChanged<List<XFile>> onFinish;
  const MyCamera({
    Key? key,
    required this.onFinish
  }) : super(key: key);

  @override
  State<MyCamera> createState() => _MyCameraState();
}

class _MyCameraState extends State<MyCamera> with WidgetsBindingObserver{

  final Globals _globals = getIt<Globals>();
  final ValueNotifier<String> _errorCamera = ValueNotifier<String>('');
  final ValueNotifier<double> _currentZoomLevel = ValueNotifier<double>(1.0);
  final ValueNotifier<List<XFile>> _fotos = ValueNotifier<List<XFile>>([]);
  
  CameraController? _controller;
  bool _isCameraInitialized = false;
  double _maxAvailableZoom = 1.0;
  double _minAvailableZoom = 1.0;
  bool _isLoding = false;
  bool _showVer = false;
  bool _showHelp = false;
  bool _showPrepareExit = false;
  int _showIndexFotoCurrent = -1;

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.bottom
      ]);
      await onNewCameraSelected(_globals.firstCamera!);
    });
  }

  @override
  void dispose() async {

    _controller?.dispose();
    _errorCamera.dispose();
    _currentZoomLevel.dispose();

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
      await onNewCameraSelected(cameraController.description);
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
          child: _screenOrientation(),
        ),
      )
    );
  }

  ///
  Widget _screenOrientation() {

    if(_showPrepareExit) {
      return Container(
        color: _globals.bgMain,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(child: _cargando()),
      );
    }

    return NativeDeviceOrientedWidget(
      landscapeLeft: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _body()
        );
      },
      landscapeRight: (context) {
        if(_isCameraInitialized) {
          return _body();
        }
        return _volteaDeviceLandscape(0, 'landscapeRight');
      },
      portraitUp: (context) {
        return _volteaDevicePortrait(-1, 'portraitUp');
      },
      portraitDown: (context) {
        return _volteaDevicePortrait(5, 'portraitDown');
      },
      fallback: (context) {

        return const Center(
          child: Text(
            'Desconocida la Orientación actual\n',
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Color(0xFFffffff)
            ),
          )
        );
      },
      useSensor: true,
    );
  }

  ///
  Widget _body() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: _controlesUi()
        ),
        RotatedBox(
          quarterTurns: -1,
          child: _camara(),
        ),
        Expanded(
          flex: 2,
          child: Container(
            constraints: const BoxConstraints.expand(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _btnTake(withIndicador: true),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<XFile>>(
                    valueListenable: _fotos,
                    builder: (_, lst, __) => _carrucelFotos(lst)
                  )
                ),
              ],
            ),
          )
        ),
      ],
    );
  }

  ///
  Widget _volteaDevicePortrait(int lado, String nameLado) {

    Size size = MediaQuery.of(context).size;

    return RotatedBox(
      quarterTurns: lado,
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.3),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _voltearImg(size.width * 0.4)
              )
            ),
            _voltearTxt(nameLado),
            SizedBox(height: size.height * 0.3),
          ],
        ),
      ),
    );
  }

  ///
  Widget _volteaDeviceLandscape(int lado, String nameLado) {

    Size size = MediaQuery.of(context).size;

    return RotatedBox(
      quarterTurns: lado,
      child: SizedBox.expand(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _voltearImg(size.width * 0.4),
            const SizedBox(width: 20),
            Expanded(child: _voltearTxt(nameLado)),
          ],
        ),
      ),
    );
  }

  ///
  Widget _voltearImg(double w) {

    return SvgPicture.asset(
        'assets/svgs/landscape.svg',
        alignment: Alignment.topCenter,
        fit: BoxFit.contain,
        width: w,
      );
  }

  ///
  Widget _voltearTxt(String nameLado) {

    return const Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        'Para lograr una unidad en las fotografías, hacemos que se '
        'tomen de manera horizontal por medio de la camara.\n\n'
        'Gira tu teléfono hacia tu lado Izquierdo para tomar la foto.',
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w200,
          color: Color(0xFFffffff)
        ),
      ),
    );
  }

  ///
  Widget _controlesUi() {

    return Container(
      color: Colors.black,
      constraints: const BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ValueListenableBuilder<List<XFile>>(
            valueListenable: _fotos,
            builder: (_, lst, __) {
              return RotatedBox(
                quarterTurns: 0,
                child: _btnCircle(
                  icono: (lst.isEmpty)
                    ? Icons.close_sharp
                    : Icons.done,
                  fnc: () async {
                    _prepareExit().then((_) {
                      Navigator.of(context).pop(false);
                    });
                  }
                ),
              );
            }
          ),
          const Spacer(),
          _btnCircle(icono: Icons.arrow_circle_up, fnc: () async {
            if(_currentZoomLevel.value > _minAvailableZoom) {
              _currentZoomLevel.value--;
              await _controller!.setZoomLevel(_currentZoomLevel.value);
            }
          }),
          const SizedBox(height: 10),
          _indicatorBy(
            ValueListenableBuilder<double>(
              valueListenable: _currentZoomLevel,
              builder: (_, txtV, __) => Text(
                '${txtV.toStringAsFixed(1)}x',
                textScaleFactor: 1,
                style: TextStyle(color: _globals.bgMain),
              ),
            )
          ),
          const SizedBox(height: 10),
          _btnCircle(icono: Icons.arrow_circle_down, fnc: () async {
            if(_currentZoomLevel.value < _maxAvailableZoom) {
              _currentZoomLevel.value++;
              await _controller!.setZoomLevel(_currentZoomLevel.value);
            }
          }),
          const Spacer(),
          _btnTake(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  ///
  Widget _camara() {

    int max = 120;
    if(_isCameraInitialized) {

      return LayoutBuilder(
        builder: (_, constraints) {

          if(_isLoding) {
            return Expanded(flex: 8, child: _cargando(width: constraints.maxWidth+max));
          }

          if(_showHelp) {
            return Expanded(
              flex: 8,
              child: HelpIconsCamera(
                width: constraints.maxWidth+max,
                onExit: (_) async {
                  await onNewCameraSelected(_globals.firstCamera!);
                  _showHelp = false;
                },
              )
            );
          }
          if(_showIndexFotoCurrent != -1) {
            return Expanded(flex: 8, child: _verFotoBig(constraints.maxWidth+max));
          }

          return AspectRatio(
            aspectRatio: 1 / _controller!.value.aspectRatio,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (detalles) => onViewFinderTap(detalles, constraints),
              child: _controller!.buildPreview()
            )
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return Expanded(flex: 8, child: _cargando(width: constraints.maxWidth+max));
      }
    );
  }

  ///
  Widget _btnCircle({
    required IconData icono,
    required Function fnc
  }) {

    return CircleAvatar(
      radius: 26,
      backgroundColor: _globals.secMain,
      child: IconButton(
        onPressed: () => fnc(),
        icon: Icon(icono),
        iconSize: 40,
        color: _globals.txtOnsecMainDark,
        padding: const EdgeInsets.all(0),
        visualDensity: VisualDensity.compact,
      )
    );
  }

  ///
  Widget _indicatorBy(Widget child) {

    return RotatedBox(
      quarterTurns: 0,
      child: Container(
        decoration: BoxDecoration(
          color: _globals.colorGreen,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child
        ),
      ),
    );
  }

  ///
  Widget _btnTake({bool withIndicador = false}) {

    double tamI= 40.0;
    double tam = 48.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if(withIndicador)
          ..._btnHelp(),
        Container(
          width: tam, height: tam,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(100)
          ),
          child: AbsorbPointer(
            absorbing: _isLoding,
            child: IconButton(
              onPressed: () async {
                if(!_showVer) {
                  await _takeFoto();
                }else{
                  _showVer = false;
                  _showIndexFotoCurrent = -1;
                  await onNewCameraSelected(_globals.firstCamera!);
                }
              },
              padding: const EdgeInsets.all(0),
              constraints: BoxConstraints(
                maxHeight: tamI, maxWidth: tamI,
                minHeight: tamI, minWidth: tamI
              ),
              iconSize: tamI,
              alignment: Alignment.center,
              color: (_showVer) ? const Color.fromARGB(255, 224, 192, 48) : Colors.white,
              icon: (_showVer) 
                ? Transform.rotate(
                  angle: 40,
                  child: const Icon(Icons.add_circle),
                )
                : const Icon(Icons.circle)
            ),
          )
        )
      ],
    );
  }

  ///
  List<Widget> _btnHelp() {

    List fotos = context.read<GestDataProvider>().campos[Campos.rFotos];
    int tot = Constantes.cantFotos - fotos.length;

    return [
      IconButton(
        padding: const EdgeInsets.all(0),
        iconSize: 35,
        constraints: const BoxConstraints(
          maxHeight: 35,
          maxWidth: 35
        ),
        color: Colors.green,
        onPressed: () {
          try {
            _controller!.pausePreview();
          } catch (_) {}
          setState(() {
            _showHelp = true;
          });
        },
        icon: const Icon(Icons.help)
      ),
      _indicatorBy(
        Text(
          '${_fotos.value.length}/$tot',
          textScaleFactor: 1,
          style: TextStyle(color: _globals.bgMain)
        ),
      )
    ];
  }

  ///
  Widget _carrucelFotos(List<XFile> lst) {

    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.symmetric(vertical: 5),
      itemCount: lst.length,
      itemBuilder: (_, index) {

        return Dismissible(
          key: Key(lst[index].path),
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3.5,
            child: Row(
              children: [
                _bgDismmiss('ELIMINAR', Icons.delete_forever),
                const Spacer(),
                _bgDismmiss('VER FOTO', Icons.remove_red_eye),
              ],
            ),
          ),
          confirmDismiss: (DismissDirection direc) {

            if(direc.name == 'endToStart') {
              try {
                _controller!.pausePreview();
              } catch (_) {}

              setState(() {
                _showVer = true;
                _showIndexFotoCurrent = index;
              });
              return Future.value(false);
            }else{
              return Future.value(true);
            }
          },
          onDismissed: (DismissDirection direc) {

            if(direc.name != 'endToStart') {
              if(lst.length == 1) {
                  _fotos.value = [];
              }else{
                int ind = _fotos.value.indexWhere((f) => f.path == lst[index].path);
                if(ind != -1) {
                  _fotos.value.removeAt(ind);
                }
              }
            }else{
              setState(() {
                _showVer = true;
              });
            }
          },
          child: _tileFotoThubn(lst[index], index)
        );
      },
    );
  }

  ///
  Widget _bgDismmiss(String label, IconData ico) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          ico, size: 35,
          color: (label == 'ELIMINAR') ? Colors.red : Colors.blue),
        const SizedBox(height: 5),
        Text(
          label,
          textScaleFactor: 1,
          style: TextStyle(
            color: _globals.txtOnsecMainLigth,
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 5),
        Icon(
          (label == 'ELIMINAR') ? Icons.arrow_forward : Icons.arrow_back,
          size: 25,
          color: (label == 'ELIMINAR') ? Colors.red : Colors.blue)
      ],
    );
  }

  ///
  Widget _tileFotoThubn(XFile foto, int index) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 13),
      padding: const EdgeInsets.all(2),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 3.5,
      decoration: BoxDecoration(
        color: _globals.txtOnsecMainDark,
        border: Border.all(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(10)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
          child: Image.file(
          File(foto.path),
          fit: BoxFit.cover,
        ),
      )
    );
  }

  ///
  Widget _cargando({double? width}) {

    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints.expand(
        height: width
      ),
      width: MediaQuery.of(context).size.height,
      child: const Center(
        child: SizedBox(
          height: 60, width: 60,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
            backgroundColor: Colors.black,
          ),
        ),
      ),
    );
  }

  ///
  Widget _verFotoBig(double width) {

    return RotatedBox(
      quarterTurns: 1,
      child: SizedBox(
        width: width,
        child: ExtendedImage.file(
          File(_fotos.value[_showIndexFotoCurrent].path),
          fit: BoxFit.contain,
          mode: ExtendedImageMode.gesture,
          clearMemoryCacheWhenDispose: true,
          enableMemoryCache: true,
          initGestureConfigHandler: (ExtendedImageState x){
            return GestureConfig(
              reverseMousePointerScrollDirection: false,
            );
          },
        ),
      ),
    );
  }

  ///
  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {

    if (_controller == null) {
      return;
    }
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    _controller!.setExposurePoint(offset);
    _controller!.setFocusPoint(offset);
  }

  ///
  Future<void> _takeFoto() async {

    List fotos = context.read<GestDataProvider>().campos[Campos.rFotos];
    int tot = Constantes.cantFotos - fotos.length;

    if(_fotos.value.length >= tot) {
      ShowDialogs.alert(
        context, 'fotosCantCam',
        hasActions: false
      ).then((res){
        res = (res == null) ? false : res;
        if(res) {
          widget.onFinish(_fotos.value);
        }
      });
      return;
    }

    setState(() { _isLoding = true; });
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final xfile = await _controller!.takePicture();
        if(_fotos.value.length < Constantes.cantFotos) {
          final tmp = List<XFile>.from(_fotos.value);
          _fotos.value.clear();
          tmp.add(xfile);
          _fotos.value = tmp;
        }
      } catch (_) {}
    });
  }

  ///
  Future<void> _prepareExit() async {

    setState(() {
      _showPrepareExit = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    await SystemChrome.restoreSystemUIOverlays();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      await _controller?.pausePreview();
      await _controller?.unlockCaptureOrientation();
      _controller?.removeListener(() { });
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 350));
    widget.onFinish(_fotos.value);
  }

  ///
  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {

    CameraController? previousCameraController = _controller;
    
    final CameraController cameraController = CameraController(
      _globals.firstCamera!,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    // Initialize controller
    try {
      await cameraController.initialize();
      await cameraController.lockCaptureOrientation(DeviceOrientation.landscapeLeft);
      cameraController.getMaxZoomLevel().then(
        (double value) => _maxAvailableZoom = value
      );
      cameraController.getMinZoomLevel().then(
        (double value) => _minAvailableZoom = value
      );
    } on CameraException catch (_) {
      _showErrInitCamera();
      return;
    }

    await cameraController.setZoomLevel(_minAvailableZoom);
    _currentZoomLevel.value = _minAvailableZoom;

    _controller = cameraController;
    _isCameraInitialized = _controller!.value.isInitialized;
    _controller!.addListener(() async {
      
      if(_isCameraInitialized) {
        if(_isLoding) {
          if (mounted) {
            
            if(MediaQuery.of(context).orientation.name != 'landscape') {
              await SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight
              ]);
            }
            setState(() {
              _isLoding = false;
            });
          }
        }
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  ///
  void _showErrInitCamera() {

    ShowDialogs.alert(
      context, 'errCam',
      hasActions: false
    ).then((res){
      res = (res == null) ? false : res;
      if(res) {
        widget.onFinish(_fotos.value);
      }
    });
  }
}
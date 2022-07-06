import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cotizo/vars/constantes.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';

class MyIm {

  static final ImagePicker _picker = ImagePicker();

  ///
  static Future<List<XFile>?> galeria() async {

    return await _picker.pickMultiImage(
      maxWidth: Constantes.maxAnchoImg
    );
  }

  ///
  static Future<XFile?> camera() async {

    return await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: Constantes.maxAnchoImg
    );
  }

  ///
  static Future<Map<String, dynamic>> prepareImage({
    XFile? foto,
    Uint8List? data,
    double minWidth = Constantes.minSize,
    double minHeight = Constantes.minSize,
  }) async {

    Map<String, dynamic> result = {};
    Size size = const Size(0,0);

    if(foto != null) {
      data = await readAsBytes(foto);
      size = getSize(data);
      Medidas medSrc  = getMedidas(data.lengthInBytes);
      result['src'] = {'size': size, 'kb': medSrc.kb, 'mb': medSrc.mb};
      result['src']['fotoName'] = foto.name;
    }
    if(data == null){ return result; }

    size = getSize(data);
    Medidas med  = getMedidas(data.lengthInBytes);
    double scale = calcScale(size: size, minWidth: minWidth, minHeight: minHeight);

    // Esta data es la que se envia al servidor.
    data = await comprimir(data, scale: scale, size: size);
    med  = getMedidas(data.lengthInBytes);
    if(result.containsKey('src')) {
      result['res'] = {'size': getSize(data), 'kb': med.kb, 'mb': med.mb, 'data':data};
    }else{
      result = {'size': getSize(data), 'kb': med.kb, 'mb': med.mb, 'data': data};
    }
    return result;
  }

  ///
  static Future<Uint8List> readAsBytes(XFile foto) async => await foto.readAsBytes();

  ///
  static Size getSize(Uint8List image) => ImageSizeGetter.getSize(MemoryInput(image));

  ///
  static Medidas getMedidas(int bytes) {
    final kb = bytes / 1024;
    final mb = kb / 1024;
    return Medidas(kb: kb, mb: mb);
  }
  
  ///
  static double calcScale({
    required Size size,
    double minWidth = Constantes.minSize,
    double minHeight = Constantes.minSize,
  }) {
    var scaleW = size.width / minWidth;
    var scaleH = size.height / minHeight;
    var scale = math.max(1.0, math.min(scaleW, scaleH));
    return scale;
  }

  ///
  static Future<Uint8List> comprimir(Uint8List list, {
    required double scale,
    required Size size
  }) async {
    
    String w = (size.width / scale).toStringAsFixed(0);
    String h = (size.height / scale).toStringAsFixed(0);

    var result = await FlutterImageCompress.compressWithList(
      list, minWidth: int.parse(w), minHeight: int.parse(h),
      quality: 72,
    );
    return result;
  }

  ///
  static saveInApp() async {

    Directory appDocDir = await getApplicationSupportDirectory();
    print('el soporte de la app');
    print(appDocDir.path);
    appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print(appDocPath);
  }
}

class Medidas {

  double kb = 0;
  double mb = 0;
  Medidas({
    required this.kb,
    required this.mb
  });
}
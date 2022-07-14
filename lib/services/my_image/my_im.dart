import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';

import '../../vars/constantes.dart';

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
  static Future<Map<String, dynamic>> getDataInitImage(XFile foto) async {

    Map<String, dynamic> result = {};
    Size size = const Size(0,0);

    Uint8List data = await _readAsBytes(foto);
    size = _getSize(data);
    final medSrc  = _getMedidas(data.lengthInBytes);
    result['size'] = size;
    result['kb'] = medSrc.kb;
    result['mb'] = medSrc.mb;
    result['fotoName'] = foto.name;
    result['data'] = data;
    return result;
  }

  ///
  static Future<Map<String, dynamic>> comprimirImage(Map<String, dynamic> info, {
    double minWidth = 1024, double minHeight = 720
  }) async {

    double scale = _calcScale(
      size: info['size'], minWidth: minWidth, minHeight: minHeight
    );
    // Esta data es la que se envia al servidor.
    Uint8List data = await _comprimir(info['data'], scale: scale, size: info['size']);
    // Recalculamos con el resultado de compresion las nuevas medias.
    final med = _getMedidas(data.lengthInBytes);
    final size = _getSize(data);
    info['size'] = size;
    info['kb'] = med.kb;
    info['mb'] = med.mb;
    info['data'] = data;
    return info;
  }

  ///
  static Future<Uint8List> _readAsBytes(XFile foto) async => await foto.readAsBytes();

  ///
  static Size _getSize(Uint8List image) => ImageSizeGetter.getSize(MemoryInput(image));

  ///
  static Medidas _getMedidas(int bytes) {
    final kb = bytes / 1024;
    final mb = kb / 1024;
    return Medidas(kb: kb, mb: mb);
  }
  
  ///
  static double _calcScale({
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
  static Future<Uint8List> _comprimir(Uint8List list, {
    required double scale, required Size size
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
  static String buildNewNameFile(String file) {

    final ext = _getExtention(file);
    return (ext.isEmpty) ? '' : '${_getNameFile()}.$ext';
  }

  ///
  static String _getNameFile() => '${DateTime.now().millisecondsSinceEpoch}';

  ///
  static String _getExtention(String file) {

    List<String> permitidas = ['jpg', 'jpeg', 'png'];
    List<String> partes = file.split('.');
    if(permitidas.contains(partes.last)) {
      return partes.last;
    }
    return '';
  }

  ///
  static Future<String> saveImageInApp(String nameFile, Uint8List bodyBytes) async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String relative = '/$nameFile';
    
    final file = File('${appDocDir.path}$relative');
    file.writeAsBytesSync(bodyBytes);
    if(file.existsSync()) { return relative; }
    return '';
  }

  ///
  static Future<File?> getImageByPath(String nameFile) async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    
    final file = File('${appDocDir.path}$nameFile');
    if(file.existsSync()) { return file; }
    return null;
  }

  ///
  static Future<String> getPathImage(String nameFile) async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    
    final file = File('${appDocDir.path}$nameFile');
    if(file.existsSync()) { return file.path; }
    return '';
  }

  ///
  static Future<bool> removeFotoInApp(String relativePath) async {

    Directory appDocDir = await getApplicationDocumentsDirectory();
    
    final file = File('${appDocDir.path}$relativePath');
    if(file.existsSync()) {
      file.deleteSync();
      return true;
    }
    return false;
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
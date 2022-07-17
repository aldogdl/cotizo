import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;

class DriverApi extends http.BaseClient {

  DriverApi(this._headers);

  final http.Client _client = http.Client();
  late final drive.DriveApi _driveApi;
  Map<String, String> _headers = {};
  set headers(Map<String, String> heads) => _headers = heads;

  ///
  Future<void> _init() async {
    _driveApi = drive.DriveApi(DriverApi(_headers));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    
    return await _client.send(request..headers.addAll(_headers));
  }

  ///
  Future<Map<String, dynamic>> upFoto(Map<String, dynamic> fotoPreparada) async {

    await _init();
    final data = Uint8List.fromList(fotoPreparada['thub']['data'].toList());
    final Stream<List<int>> mediaStream = Future.value(
      data.toList()
    ).asStream().asBroadcastStream();
    
    if(fotoPreparada['src'].containsKey('fotoName')) {

      if(fotoPreparada['src']['fotoName'].contains('.')) {

        List<String> partes = fotoPreparada['src']['fotoName'].split('.');
        var driveFile = drive.File();
        driveFile.name = '${DateTime.now().millisecondsSinceEpoch}.${partes.last}';
        final upFileRes = await _driveApi.files.create(
          driveFile,
          uploadMedia: drive.Media(mediaStream, data.lengthInBytes),
        );

        if(upFileRes.id != null) {
          fotoPreparada['api'] = {
            'id': upFileRes.id, 'drive_id': upFileRes.driveId,
            'ext': upFileRes.fileExtension, 'name': driveFile.name
          };
        }
      }
      return fotoPreparada;
    }
    return {'err':'No se encontró el nombre de la imagen'};
  }

  ///
  Future<drive.FileList> getAllFotos() async {

    await _init();
    return await _driveApi.files.list(
      q: null,
      pageSize: 50,
      $fields: 'nextPageToken, files(id, name, mimeType, thumbnailLink)'
    );
  }

  ///
  void prueba() async {

    await _init();
    // final Stream<List<int>> mediaStream = Future.value([104, 105]).asStream().asBroadcastStream();
    // print(_accountSng.account.email);
    // print(_headers);
    
    // var media = drive.Media(mediaStream, 2);
    var driveFile = drive.File();
    driveFile.name = "nuevo_mundo.txt";
    // final result = await _driveApi.files.create(driveFile, uploadMedia: media);
    
    // print("${result.appProperties}");
    // print("${result.description}");
    // print("${result.exportLinks}");
    // print("${result.fileExtension}");
    // print("${result.fullFileExtension}");
    // print("${result.id}");
    // print("${result.iconLink}");
    // print("${result.mimeType}");
    // print("${result.name}");
    // print("${result.originalFilename}");
    // print("${result.size}");
    // print("${result.thumbnailLink}");
    // print("${result.webContentLink}");
    // print('https://drive.google.com/file/d/${result.id}/view?usp=sharing');
    // print('https://drive.google.com/file/d/10l6B19M0kRc-ZX-5dtpfD8jaizJRteBL/view?usp=sharing');
  }
}
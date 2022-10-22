class PushInEntity {
  
  int id = 0;
  String titulo = 'Oportunidad de Venta';
  String subtitulo = 'Tienes más piezas para cotizar :)\nAutoparNet Informa.';
  String imgBig = '0';
  String payload = '';

  ///
  void fromServer(Map<String, dynamic> data) {
    
    id = data['pza']['id'];
    titulo = data['pza']['titulo'];
    subtitulo = data['pza']['subtitulo'];
    imgBig = data['pza']['imgBig'];
    payload = data['link'];
  }
}
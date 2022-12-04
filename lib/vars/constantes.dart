class Constantes {

  static const int pasosCot = 3;
  static const int cantFotos = 8;
  static const double minSize = 320;
  static const double maxAnchoImg = 1024;
  static const double marginBubble = 0.12;

  static const double fontSize = 18.5;
  static const double fontSizeMin = 13.5;
  static const double heightTxt = 1.25;
  static const List<String> codesTxt = ['*','_','-', '+'];

  ///
  static String parseFrom(String to, String from) {

    String res = 'unknow';
    WhereReg.values.map((e) {
      if(e.name.startsWith(from)) {
        final pre = to.substring(2, to.length);
        res = '$from$pre';
        return;
      }
    }).toList();

    return res;
  }
}

/// aph Apertura de app desde Home,
/// apl Apertura de app desde Link,
/// appo Apertura de app desde Push Out,
/// appi Apertura de app desde Push In,
/// 
/// nth No Tengo desde Home,
/// ntl No Tengo desde Link,
/// ntpo No Tengo desde Push Out,
/// ntpi No Tengo desde Push In,
/// ntca No Tengo desde Carnada en Estanque
/// 
/// seh Vista desde Home,
/// sel Vista desde Link,
/// sepo Vista desde Push out,
/// sepi Vista desde Push In,
/// seca Vista desde Carnada en Estanque
/// 
/// apr Pieza Apartada,
enum WhereReg {
  aph, apl, appo, appi, nth, ntl, ntpo, ntpi, ntca, seh, sel, sepo, sepi, seca,
  apr,
}

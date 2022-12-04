import '../config/sngs_manager.dart';
import '../repository/soli_em.dart';
import '../vars/globals.dart';

class AnsueloEntity {

  final solEm = SoliEm();
  
  int ido = 0;
  int ct  = 0;
  int md  = 0;
  int mk  = 0;
  // El indice de la ubicacion de la orden en el array items ordenes en cache
  int idx = -1;

  /// Construimos el link que simula un ingreso desde el link de WhatsApp
  Future<AnsueloEntity?> buildAnsuelo(int idOrden, int idAuto, int indice) async {

    final solEm = SoliEm();
    final globals = getIt<Globals>();
    final auto = await solEm.getAutoById(idAuto);
    if(auto != null) {
      ido = idOrden;
      ct  = globals.idUser;
      md  = auto.modelo;
      mk  = auto.marca;
      idx = indice;
      return this;
    }
    return null;
  }

  ///
  Map<String, dynamic> toJson() {

    return {
      'ido': ido,
      'ct' : ct,
      'md' : md,
      'mk' : mk,
      'idx': idx
    };
  }
}
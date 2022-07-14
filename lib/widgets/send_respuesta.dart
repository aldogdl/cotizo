import 'package:cotizo/widgets/counter_load.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../entity/orden_entity.dart';
import '../entity/inventario_entity.dart';
import '../entity/share_data_orden.dart';
import '../providers/gest_data_provider.dart';
import '../providers/signin_provider.dart';
import '../repository/inventario_repository.dart';
import '../vars/globals.dart';
import '../vars/enums.dart';

class SendRespuesta extends StatefulWidget {

  final int idPieza;
  final Globals globals;
  final OrdenEntity orden;
  final GestDataProvider prov;
  final ValueChanged<void> onFinish;
  const SendRespuesta({
    Key? key,
    required this.prov,
    required this.globals,
    required this.orden,
    required this.idPieza,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<SendRespuesta> createState() => _SendRespuestaState();
}

class _SendRespuestaState extends State<SendRespuesta> {
  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.globals.bgMain,
            Colors.black
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        )
      ),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 3,
            color: Colors.green,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 30, top: 30),
            child: CounterLoad()
          ),
          StreamBuilder<String>(
            stream: _send(context),
            builder: (_, AsyncSnapshot snap) {

              if(snap.data.toString().startsWith('Listo')) {
                Future.delayed(const Duration(milliseconds: 1000), (){
                  widget.onFinish(_);
                });
              }
              return Column(
                children: [
                  Text(
                    snap.data,
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  if(snap.data.toString().startsWith('ERROR'))
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text(
                        'Reintentarlo',
                        textScaleFactor: 1,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    )
                ],
              );
            },
            initialData: 'Iniciando...',
          )
        ],
      ),
    );
  }

  ///
  Stream<String> _send(BuildContext context) async* {

    yield 'Preparandolo TODO';
    
    final share = SharedDataOrden(); 
    final invEm = InventarioRepository();
    final data  = widget.prov.getData();
    final own   = context.read<SignInProvider>().getIdOwn();

    share.auto  =  await share.solEm.getAutoById(widget.orden.auto);
    share.pieza =  await share.solEm.getPiezaById(widget.idPieza);
    final tiempo= DateTime.now();

    InventarioEntity inv = InventarioEntity();
    inv.id      = tiempo.millisecondsSinceEpoch;
    inv.auto    = share.auto!.id;
    inv.pieza   = share.pieza!.id;
    inv.idOrden = widget.orden.id;
    inv.idPieza = widget.idPieza;
    inv.costo   = double.parse(data['costo']); 
    inv.deta    = data['deta'];
    inv.created = tiempo.toIso8601String();

    await Future.delayed(const Duration(milliseconds: 250));

    yield 'Revisando procesos de Imágenes';
    await Future.delayed(const Duration(milliseconds: 250));
    if(!widget.prov.isFinishProcessImage) {
      
      while (!widget.prov.isFinishProcessImage) {
        
        final sub = widget.prov.dataSaveImg.length;
        final tot = widget.prov.campos[Campos.rFotos].length;
        yield 'Guardadas $sub de $tot fotos [EN PROCESO]';
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    inv.fotos = widget.prov.dataSaveImg;

    yield 'Imágenes Listas!!';
    await Future.delayed(const Duration(milliseconds: 250));

    // Dado que las imagenes ya estan en el servidor.
    // Primero guardamos los datos en el dispositivo como Inventario.
    yield 'Guardando Inventario';
    invEm.setBoxInv(inv);
    Map<String, dynamic> dataSend = inv.toServer();
    dataSend['idCamp'] = widget.globals.idCampaingCurrent;
    dataSend['idsFromLink'] = widget.globals.idsFromLinkCurrent;
    dataSend['own'] = own;
    await Future.delayed(const Duration(milliseconds: 250));

    yield 'Enviando Datos de Cotización';
    final result = await invEm.setRespToServer(dataSend);
    print(dataSend);
    print(result);
    if(!result['abort']) {
      yield 'Listo, Redirigiendo...';
    }else{
      yield 'ERROR!, ${result['body']}';
    }
  }
}
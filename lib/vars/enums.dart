enum ChatFrom {anet, user}
enum ChatTip {dialog, dialogFrm, msg, interactive, image}
enum Campos {
  none, rFotos, isValidFotos, rDeta, isValidDeta, rCosto, isValidCosto, isCheckData
}
enum ChatKey {
  none, know, userRes, getTime, estasListo, alertFotosLogos, getAlertFotosLogos,
  rFotos, getAwaitFotos, errAwaitFotos, putDeta, rDeta, putCosto, rCosto, checkData
}
enum HiveBoxs {
  account, autos, chat, contact, inventario, marca, modelo, pieza, noTengo,
  configapp, pushIn, apartados, orden
}

const configappHT = 1;
const autosHT = 2;
const contactHT = 3;
const inventarioHT = 4;
const marcaHT = 5;
const modeloHT = 6;
const piezaHT = 7;
const accountHT = 8;
const noTengoHT = 9;
const pushIn = 10;
const apartadosHT = 11;
const ordenHT = 12;
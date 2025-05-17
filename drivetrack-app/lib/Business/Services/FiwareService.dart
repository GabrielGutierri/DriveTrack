import 'dart:convert';
import 'package:http/http.dart';
import 'package:drivetrack/Domain/TO/RetornoDispositivoFiwareTO.dart';
import 'package:drivetrack/Domain/TO/RetornoErroFiwareTO.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Fiwareservice {
  static final String ip = "20.62.95.153";

  Future<bool> VerificaDispositivoExistente(
      String deviceID, String deviceName, String nome) async {
    var url = Uri.parse("http://$ip:1026/v2/entities/$deviceName");
    Response response = await http.get(url,
        headers: {"fiware-service": "smart", "fiware-servicepath": "/"});
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (respostaGetValida(response, deviceName)) {
        await ArmazenarValoresCarro(deviceID, deviceName, nome);
        return true;
      }
      throw new Exception();
    } else {
      if (respostaNaoExisteValida(response)) {
        return false;
      }
      throw new Exception();
    }
  }

  bool respostaGetValida(Response response, String deviceName) {
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    RetornoDispositivoFiwareTO dispositivo =
        RetornoDispositivoFiwareTO.fromJson(jsonMap);
    return dispositivo.id == deviceName && dispositivo.type == 'Carro';
  }

  bool respostaNaoExisteValida(Response response) {
    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    RetornoErroFiwareTO retornoErro = RetornoErroFiwareTO.fromJson(jsonMap);

    return retornoErro.description ==
        "The requested entity has not been found. Check type and id";
  }

  Future<void> ArmazenarValoresCarro(String deviceID, String deviceName, String nomeCarro) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceID', deviceID);
    await prefs.setString('deviceName', deviceName);
    await prefs.setString('nomeCarro', nomeCarro);
    await prefs.setString('placaCarro', deviceID);
  }
}

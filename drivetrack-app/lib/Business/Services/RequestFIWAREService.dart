import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:drivetrack/Business/Services/FiwareService.dart';
import 'package:drivetrack/Business/Utils/TrataMensagemOBD.dart';
import 'package:drivetrack/Business/Utils/TrataMensagemSensores.dart';
import 'package:drivetrack/Domain/entities/DadoCarro.dart';
import 'package:drivetrack/Domain/entities/DadoException.dart';
import 'package:drivetrack/Domain/entities/DadoRequisicao.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RequestFIWAREService {
  final Box<DadoRequisicao> boxRequisicao =
      Hive.box<DadoRequisicao>('tbFilaRequisicao');
  static late String deviceName;

  Future<bool> validarDadosPendentes() async {
    Box<DadoCarro> boxDados = await Hive.openBox('tbFilaDados');
    if (boxDados.values.isEmpty == false ||
        boxRequisicao.values.isEmpty == false) {
      return true;
    }
    return false;
  }

  Future<void> trataDadosOBD() async {
    Box<DadoCarro> boxDados = await Hive.openBox('tbFilaDados');
    var dadosCarro = boxDados.values;

    for (var dado in dadosCarro) {
      Map<String, dynamic> body = {
        "velocidade": {
          "type": "float",
          "value": TrataMensagemOBD.TrataMensagemVelocidade(dado.velocidade)
        },
        "rpm": {
          "type": "float",
          "value": TrataMensagemOBD.TrataMensagemRPM(dado.rpm)
        },
        "pressure": {
          "type": "float",
          "value": TrataMensagemOBD.TrataMensagemIntakePressure(
              dado.pressaoColetorAdmissao)
        },
        "temperature": {
          "type": "float",
          "value": TrataMensagemOBD.TrataMensagemIntakeTemperature(
              dado.tempArAdmissao)
        },
        "engineload": {
          "type": "float",
          "value": TrataMensagemOBD.TrataMensagemEngineLoad(dado.engineLoad)
          
        },
        "throttlePosition": {
          "type": "float",
          "value": TrataMensagemOBD.TrataMensagemThrottlePosition(
               dado.throttlePosition)
        },
        "location": {
          "type": "geo:json",
          "value": {
            "type": "Point",
            "coordinates": [dado.latitude, dado.longitude] // Coordenadas padrão
          }
        },
        'acelerometroEixoX': {'type': 'float', 'value': dado.aceleracaoX},
        'acelerometroEixoY': {'type': 'float', 'value': dado.aceleracaoY},
        'acelerometroEixoZ': {'type': 'float', 'value': dado.aceleracaoZ},
        'giroscopioRow': {
          'type': 'float',
          'value': TrataMensagemSensores.CalculaGiroscopioRow(
              dado.aceleracaoX, dado.aceleracaoY, dado.aceleracaoZ)
        },
        'giroscopioPitch': {
          'type': 'float',
          'value': TrataMensagemSensores.CalculaGiroscopioPitch(
              dado.aceleracaoY, dado.aceleracaoX, dado.aceleracaoZ)
        },
        'giroscopioYaw': {
          'type': 'float',
          'value': TrataMensagemSensores.CalculaGiroscopioYaw(dado.giroscopioZ)
        },
        "dataColetaDados": {
          "type": "Text",
          "value": dado.dataColetaDados.toString()
        },
        "idCorrida": {"type": "float", "value": dado.idCorrida}
      };
      DadoRequisicao request = new DadoRequisicao();
      request.status = 1;
      request.requisicao = jsonEncode(body);
      await boxRequisicao.add(request);
      await boxDados.delete(dado.key);
    }
  }

  Future<void> rotinaRequestFIWARE() async {
    var dadosRequisicao =
        boxRequisicao.values.where((dado) => dado.status == 1);

    for (var dadoCarro in dadosRequisicao) {
      //ver se tem internet aqui, se nao tiver, sair do método
      final result = await InternetAddress.lookup('google.com');
      //se nao tiver net, ele retorna uma exceção
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        dadoCarro.status = 2;
        await boxRequisicao.put(dadoCarro.key, dadoCarro);
        if (deviceName != "") {
          String ip = Fiwareservice.ip;
          String urlUpdate = 'http://$ip:1026/v2/entities/$deviceName/attrs';
          var url = Uri.parse(urlUpdate);
            await http.post(url, body: dadoCarro.requisicao, headers: {
              "Content-Type": "application/json",
              "fiware-service": "smart",
              "fiware-servicepath": "/"
            });
        }
      } else {
        return;
      }
    }
  }

  Future<void> setDeviceName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    deviceName = prefs.getString('deviceName') ?? "";
  }

  Future<void> RotinaLimpeza() async {
    int recallInternetStatus = 0;
    while (recallInternetStatus < 10) {
      try {
        //Ver se sobrou algum dado das outras tabelas.
        await trataDadosOBD();
        await rotinaRequestFIWARE();
        await LimpaTabelaOBD();
        await LimpaTabelaRequisicao();
        await SubirExceptions();
        return; //se chegar aqui, não deu nenhum erro com internet
      } catch (e) {
        recallInternetStatus += 1;
      }
    }
    // await LimpaTabelaOBD();
    // await LimpaTabelaRequisicao();
  }

  Future<void> LimpaTabelaOBD() async {
    Box<DadoCarro> boxDados = await Hive.openBox('tbFilaDados');
    var dadosCarro = boxDados.values;

    for (var dado in dadosCarro) {
      await boxDados.delete(dado.key);
    }
  }

  Future<void> LimpaTabelaRequisicao() async {
    var dadosRequisicao = boxRequisicao.values;
    for (var requisicao in dadosRequisicao) {
      await boxRequisicao.delete(requisicao.key);
    }
  }

  Future<void> SubirExceptions() async {
    Box<DadoException> boxDados = await Hive.openBox('tbException');
    var dadosException = boxDados.values;

    for (var exception in dadosException) {
      //ver se tem internet aqui, se nao tiver, sair do método
      final result = await InternetAddress.lookup('google.com');
      //se nao tiver net, ele retorna uma exceção
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        String dataException = exception.data.toString();
        String mensagemTratada = TrataMensagemException(exception.mensagem);
        Map<String, dynamic> body = {
          "mensagem": {
            "type": "Text",
            "value": "$dataException: $mensagemTratada"
          },
          "stackTrace": {"type": "Text", "value": "VAZIO"},
          "data": {"type": "Text", "value": exception.data.toString()}
        };
        if (deviceName != "") {
          String deviceException = deviceName + "Exception";
          String ip = Fiwareservice.ip;
          String urlUpdate =
              'http://$ip:1026/v2/entities/$deviceException/attrs';
          var url = Uri.parse(urlUpdate);
           await http.post(url, body: jsonEncode(body), headers: {
             "Content-Type": "application/json",
             "fiware-service": "smart",
             "fiware-servicepath": "/"
           });
          await boxDados.delete(exception.key);
        }
      } else {
        return;
      }
    }
  }

  String TrataMensagemException(String mensagem) {
    RegExp regex = RegExp(r"[()=']");
    String result = mensagem.replaceAll(regex, "");
    return result;
  }

  static Future<int> ultimoIdCorrida() async {
    String ip = Fiwareservice.ip;
    var url = Uri.parse(
        "http://$ip:8666/STH/v1/contextEntities/type/iot/id/$deviceName/attributes/idCorrida?lastN=1");

    Response response = await http.get(
      url,
      headers: {"fiware-service": "smart", "fiware-servicepath": "/"},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Decodifica o JSON
      final jsonResponse = jsonDecode(response.body);

      // Navega até attributes
      final attributes = jsonResponse["contextResponses"]?[0]["contextElement"]
          ?["attributes"] as List?;

      if (attributes != null && attributes.isNotEmpty) {
        // Navega até values
        final values = attributes[0]["values"] as List?;

        if (values != null && values.isNotEmpty) {
          // Obtém attrValue
          final attrValue = values[0]["attrValue"] as int?;

          if (attrValue != null) {
            // Converte e incrementa idCorrida
            return attrValue + 1;
          }
        }
      }
      return 1; // Valor padrão para idCorrida
    }
    return 0;
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import 'package:drivetrack/Business/Services/FiwareService.dart';
import 'package:drivetrack/Business/Services/RequestFIWAREService.dart';
import 'package:drivetrack/Domain/entities/IdentificacaoVeiculo.dart';

class IdentificacaoCarroController {
  final Fiwareservice _fiwareservice;
  final RequestFIWAREService _requestService;
  final Box<IdentificacaoVeiculo> boxVeiculo =
      Hive.box('tbIdentificacaoVeiculo');
  IdentificacaoCarroController(this._fiwareservice, this._requestService);

  Future<bool> validarCarro(String nome, String placa) async {
    String deviceName = "urn:ngsi-ld:$nome:$placa";
    return await _fiwareservice.VerificaDispositivoExistente(placa, deviceName, nome);
  }

  Future<bool> validarDadosPendentes() async {
    bool pendente = await _requestService.validarDadosPendentes();
    return pendente;
  }

  Future sincronizarDados() async {
    await _requestService.setDeviceName();
    await _requestService.RotinaLimpeza();
  }

  recuperaVeiculoSalvo() async {
    IdentificacaoVeiculo veiculo =
        new IdentificacaoVeiculo(nome: "", placa: "");
    if (boxVeiculo.values.length > 0) {
      var veiculoBanco = boxVeiculo.values.first;
      veiculo.nome = veiculoBanco.nome;
      veiculo.placa = veiculoBanco.placa;
    }
    return veiculo;
  }

  salvarVeiculo(IdentificacaoVeiculo veiculo) async {
    var boxValues = boxVeiculo.values;
    for (var v in boxValues) {
      await boxVeiculo.delete(v);
    }

    await boxVeiculo.add(veiculo);
  }
}

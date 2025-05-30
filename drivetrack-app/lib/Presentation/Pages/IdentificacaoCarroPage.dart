import 'package:flutter/material.dart';
import 'package:drivetrack/Business/Controllers/IdentificacaoCarroController.dart';
import 'package:drivetrack/Business/Utils/MetodosUtils.dart';
import 'package:drivetrack/Domain/entities/IdentificacaoVeiculo.dart';
import 'package:drivetrack/IoC/DependencyFactory.dart';
import 'package:drivetrack/Presentation/Pages/HomePage.dart';

class IdentificacaoCarroPage extends StatefulWidget {
  final IdentificacaoCarroController _identificacaoCarroController;

  const IdentificacaoCarroPage(this._identificacaoCarroController, {super.key});
  @override
  _IdentificacaoCarroPageState createState() =>
      _IdentificacaoCarroPageState(_identificacaoCarroController);
}

class _IdentificacaoCarroPageState extends State<IdentificacaoCarroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final IdentificacaoCarroController _identificacaoCarroController;

  _IdentificacaoCarroPageState(this._identificacaoCarroController);

  @override
  void initState() {
    super.initState();
    _obterIdentificacaoVeiculoSalva();
  }

  Future<void> _obterIdentificacaoVeiculoSalva() async {
    IdentificacaoVeiculo veiculoSalvo =
        await _identificacaoCarroController.recuperaVeiculoSalvo();

    _nomeController.text = veiculoSalvo.nome;
    _placaController.text = veiculoSalvo.placa;
  }

  String? _mensagemErro;
  void _loginOuCadastrar() async {
    String nome = _nomeController.text;
    String placa = _placaController.text;

    if (nome.isEmpty || placa.isEmpty) {
      setState(() {
        _mensagemErro = 'Por favor, insira o nome e a placa do carro.';
      });
      return;
    }

    bool conexaoInternet = await Metodosutils.VerificaConexaoInternet();
    if (!conexaoInternet) {
      setState(() {
        _mensagemErro =
            'Sem conexão com internet. Não será possível usar o aplicativo!';
      });
      return;
    }

    try {
      
      bool existe = await _identificacaoCarroController.validarCarro(nome, placa);
      //bool existe = true;
      if (existe) {
        await sincronizarDados();
        IdentificacaoVeiculo veiculo =
            new IdentificacaoVeiculo(nome: nome, placa: placa);
        await _identificacaoCarroController.salvarVeiculo(veiculo);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _mensagemErro = 'O carro informado não existe!';
        });
        return;
      }
    } catch (ex) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(title: Text('ERRO!'));
          });
    }
  }

  Future<void> sincronizarDados() async {
    bool dadosPendentes =
        await _identificacaoCarroController.validarDadosPendentes();
    if (dadosPendentes) {
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            elevation: 8, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), 
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Sincronizando dados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );
      try {
        await _identificacaoCarroController.sincronizarDados();
      } finally {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Carro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do carro'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _placaController,
                decoration: const InputDecoration(labelText: 'Placa do carro'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _loginOuCadastrar,
                child: const Text('Entrar'),
              ),
              if (_mensagemErro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:aprendendo_firebase/models/pessoa.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference pessoasDb;

  final nomeController = TextEditingController();
  final idadeController = TextEditingController();
  final _formPessoaKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    pessoasDb = database.ref('pessoas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprendendo Firebase'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //_cadastrarRonaldo();
          var pessoa = await dialogCadastrarPessoa();
          if (pessoa != null) {
            var chave = pessoasDb.push().key;
            pessoasDb.child(chave!).set(pessoa.toJSON());
            exibirSnackBar('Pessoa cadastrada com sucesso!');
          }
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: pessoasDb.onValue,
          builder: (context, snapshot) {
            return _bodyBuilder(snapshot);
          },
        ),
      ),
    );
  }

  Widget _bodyBuilder(AsyncSnapshot<DatabaseEvent> snapshot) {
    if (snapshot.hasData &&
        !snapshot.hasError &&
        snapshot.data!.snapshot.value != null) {
      var resultado = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

      var listWidgets = <Widget>[];

      resultado.forEach((key, value) {
        var pessoa = Pessoa.fromJSON(value);
        listWidgets.add(listTilePessoa(key, pessoa));
      });

      return Column(
        children: listWidgets,
      );
    } else {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: const [
            Text('Nenhuma pessoa cadastrada.'),
            Text('Clique em + para começar!'),
          ],
        ),
      ));
    }
  }

  ListTile listTilePessoa(key, Pessoa pessoa) {
    return ListTile(
      title: Text("${pessoa.nome}"),
      subtitle: Text("${pessoa.idade}"),
      trailing: Wrap(
        children: [
          IconButton(
            onPressed: () async {
              nomeController.text = pessoa.nome!;
              idadeController.text = pessoa.idade!.toString();
              var novaPessoa = await dialogCadastrarPessoa();
              if (novaPessoa != null) {
                pessoasDb.child(key).update(novaPessoa.toJSON());
                exibirSnackBar('Pessoa alterada com sucesso!');
              }
              nomeController.clear();
              idadeController.clear();
            },
            icon: const Icon(Icons.edit),
            color: Colors.blue,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () {
              pessoasDb.child(key).remove();
            },
            icon: const Icon(Icons.delete),
            color: Colors.red,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Future<Pessoa?> dialogCadastrarPessoa() async {
    return await showDialog<Pessoa>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cadastrar Pessoa'),
          content: SingleChildScrollView(
            child: Form(
              key: _formPessoaKey,
              child: ListBody(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Nome',
                      ),
                      controller: nomeController,
                      validator: validarNome,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Idade',
                      ),
                      controller: idadeController,
                      validator: validarIdade,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _formPessoaKey.currentState!.reset();
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                if (_formPessoaKey.currentState!.validate()) {
                  var nome = nomeController.text;
                  var idade = int.parse(idadeController.text);
                  var pessoa = Pessoa(
                    nome: nome,
                    idade: idade,
                  );
                  _formPessoaKey.currentState!.reset();
                  Navigator.of(context).pop(pessoa);
                }
              },
              child: const Text('SALVAR'),
            ),
          ],
        );
      },
    );
  }

  String? validarNome(String? value) {
    if (value!.isEmpty) {
      return 'Preencha o seu nome';
    }
    if (value!.length < 3) {
      return 'O nome deve ter ao menos 3 caracteres';
    }
    return null;
  }

  String? validarIdade(String? value) {
    if (value!.isEmpty) {
      return 'Preencha a sua idade';
    }
    try {
      var conversao = int.parse(value);
      if (conversao <= 0) {
        return 'A idade deve ser 0 ou superior';
      }
      return null;
    } catch (e) {
      return 'Idade inválida';
    }
  }

  exibirSnackBar(String texto) {
    var snackBar = SnackBar(
      content: Text(texto),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

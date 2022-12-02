import 'package:aprendendo_firebase/models/pessoa.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference pessoasDb;

  @override
  void initState() {
    super.initState();
    pessoasDb = database.ref('pessoas');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aprendendo Firebase'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cadastrarRonaldo();
        },
        child: Icon(Icons.add),
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
        child: Text('Não foram encontradas pessoas!'),
      ));
    }
  }

  ListTile listTilePessoa(key, Pessoa pessoa) {
    return ListTile(
      leading: IconButton(
        onPressed: () {
          var novoRivaldo = Pessoa(
            nome: 'Rivaldo',
            idade: 50,
          );
          pessoasDb.child(key).update(novoRivaldo.toJSON());
        },
        icon: Icon(Icons.edit),
        color: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      title: Text("${pessoa.nome}"),
      subtitle: Text("${pessoa.idade}"),
      trailing: IconButton(
        onPressed: () {
          pessoasDb.child(key).remove();
        },
        icon: Icon(Icons.delete),
        color: Colors.red,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _cadastrarRonaldo() {
    var novoRonaldo = Pessoa(
      nome: 'Ronaldo',
      idade: 46,
    );
    var chave = pessoasDb.push().key;
    pessoasDb.child(chave!).set(novoRonaldo.toJSON());
  }
}

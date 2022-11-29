import 'package:aprendendo_firebase/pages/mensagem.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference chats;
  var mensagens = <String>[];

  @override
  initState() {
    super.initState();
    chats = FirebaseDatabase.instance.ref('chats');
  }

  // https://www.kodeco.com/24346128-firebase-realtime-database-tutorial-for-flutter
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aprendendo Firebase'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String? newKey = chats.push().key;

          final mensagem = {
            'mensagem': 'Oi pessoal!',
          };

          chats.child(newKey!).set(mensagem);
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: chats.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  !snapshot.hasError &&
                  snapshot.data!.snapshot.value != null) {
                mensagens.clear();
                var data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                data.forEach((key, value) {
                  mensagens.add(value['mensagem']);
                });
              }
              return Column(
                children: [for (var mensagem in mensagens) Text(mensagem)],
              );
            },
          ),
        ],
      ),
    );
  }
}

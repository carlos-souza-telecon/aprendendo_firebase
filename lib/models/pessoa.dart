class Pessoa {
  String? nome;
  int? idade;

  Pessoa({this.nome, this.idade});

  Map<String, Object?> toJSON() {
    return {'nome': nome, 'idade': idade};
  }

  static Pessoa fromJSON(dynamic json) {
    return Pessoa(nome: json['nome'], idade: json['idade']);
  }
}

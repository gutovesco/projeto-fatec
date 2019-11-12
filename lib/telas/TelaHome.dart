import 'package:app_teste/activities/MinhasPublicacoes.dart';
import 'package:app_teste/activities/Publicar.dart';
import 'package:app_teste/model/Publicacao.dart';
import 'package:app_teste/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth fireAuth = FirebaseAuth.instance;
  Future<FirebaseUser> firebaseUser;
  int _selecionado = 0;
  bool telaTurma = false;
  String _telaAtual = "Home";
  Future<Usuario> usuario;
  Usuario dadosUsuario;

  Future<Usuario> recuperarDados() async {
    FirebaseUser user = await fireAuth.currentUser();
    if (user != null) {
      FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
      DatabaseReference dataRef = firebaseDatabase.reference();
      String idUsuario = user.uid;
      Usuario userDados = Usuario();

      var dados =
          dataRef.child("usuarios").child(idUsuario).child("dadosUsuario");

      print(dados);
      print("eii aqui");

      await dados.once().then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        userDados.idUsuario = idUsuario;
        userDados.email = values["email"];
        userDados.nome = values["nome"];
        userDados.tipoUsuario = values["tipoUsuario"];
        userDados.imagemPerfil = values["imagemPerfil"];
        userDados.curso = values["curso"];
      });

      setState(() {
        dadosUsuario = userDados;
      });

      return userDados;
    }
  }

  @override
  void initState() {
    super.initState();
    usuario = recuperarDados();
    firebaseUser = verificarLoginUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_telaAtual),
        actions: <Widget>[
          FutureBuilder<FirebaseUser>(
            future: firebaseUser,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return IconButton(
                  icon: CircleAvatar(
                    backgroundImage: ExactAssetImage("imagens/fundo.png"),
                    radius: 16,
                  ),
                  onPressed: () {
                    verificarEstadoLogin(snapshot);
                  },
                );
              } else {
                return IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    verificarEstadoLogin(snapshot);
                  },
                );
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: myBottomBar(),
      body: Center(
        child: HomeHome(),
      ),
    );
  }

  void verificarEstadoLogin(Object snapshot) async {
    FirebaseUser fireUser = await fireAuth.currentUser();
    if (fireUser != null && usuario != null) {
      Navigator.pushNamed(context, "/perfil");
    } else {
      Navigator.pushNamed(context, "/autenticacao");
    }
  }

  Future<FirebaseUser> verificarLoginUsuario() async {
    return await fireAuth.currentUser();
  }

  FutureBuilder<dynamic> myBottomBar() {
    return FutureBuilder<Usuario>(
      future: usuario,
      builder: (context, snapshot) {
        bool tipoUsuario = false;

        if (snapshot.data != null) {
          String tipoUser = snapshot.data.tipoUsuario;
          if (tipoUser == "Professor" ||
              tipoUser == "Diretor" ||
              tipoUser == "Coordenador") {
            tipoUsuario = true;
          } else {
            tipoUsuario = false;
          }
        } else {
          tipoUsuario = false;
        }

        return Visibility(
          visible: tipoUsuario,
          child: BottomNavigationBar(
            currentIndex: _selecionado,
            onTap: (indice) {
              if (indice == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Publicar(
                              user: snapshot.data,
                            )));
              }

              if (indice == 2) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MinhasPublicacoes()));
              }

              setState(() {
                _selecionado = indice;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text("Home")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.send), title: Text("Publicar")),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), title: Text("Publicações"))
            ],
          ),
        );
      },
    );
  }

  Widget verificarTipoIconCarregar() {
    if (firebaseUser != null) {
      return CircleAvatar(
        backgroundImage: ExactAssetImage("imagens/fundo.png"),
        radius: 16,
      );
    } else {
      return Icon(Icons.account_circle);
    }
  }
}

class HomeHome extends StatefulWidget {
  @override
  _HomeHomeState createState() => _HomeHomeState();
}

class _HomeHomeState extends State<HomeHome> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Publicacao>>(
      future: buscarDadosPublicacao(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.waiting:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Carregando..."),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
            break;
          case ConnectionState.done:
            if (snapshot.data.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Não foi possível carregar os dados!"),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, indice) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(2, 2, 2, 5),
                    child: Card(
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              visible: true,
                              child: Text("Titulo"),
                            ),
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: true,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        ExactAssetImage("imagens/fundo.png"),
                                  ),
                                ),
                                Visibility(
                                  visible: true,
                                  child: Text("Nome do professor"),
                                )
                              ],
                            ),
                            Visibility(
                              visible: true,
                              child: Divider(),
                            ),
                            Visibility(
                              visible: true,
                              child: SafeArea(
                                child: Text("Descricao"),
                              ),
                            ),
                            Visibility(
                              visible: true,
                              child: Divider(),
                            ),
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: true,
                                  child: Text("22/05"),
                                ),
                                Visibility(
                                  visible: true,
                                  child: Text(" às 19:30"),
                                )
                              ],
                            ),
                          ],
                        )),
                  );
                },
              );
            }
            break;
        }
      },
    );
  }

  Future<List<Publicacao>> buscarDadosPublicacao() async {
    List<Publicacao> listPublicacoes = List();



    return listPublicacoes;
  }
}

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
        child: HomeHome(dadosUsuario),
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

  Usuario usuario;

  HomeHome(this.usuario);

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
                  
                  String conData = "";
                  String conHora = "";
                  String conDescricao = "";
                  String urlImagem = "";

                  var _data = false;
                  var _descricao = false;
                  var _urlImagem = false;

                  Publicacao publicacao = snapshot.data[indice];
                  String conTitulo = publicacao.titulo;

                  if(publicacao.hora != null && publicacao.hora.isNotEmpty){
                      _data = true;
                      conHora = " às " + publicacao.hora;
                      conData = publicacao.data;
                  }

                  if(publicacao.descricao != null && publicacao.descricao.isNotEmpty){
                    _descricao = true;
                    conDescricao = publicacao.descricao;
                  }

                  return Padding(
                    padding: EdgeInsets.fromLTRB(2, 2, 2, 5),
                    child: Card(
                        elevation: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              visible: true,
                              child: Text(conTitulo),
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
                                  child: Text(publicacao.usuario.nome),
                                )
                              ],
                            ),
                            Visibility(
                              visible: _descricao,
                              child: Divider(),
                            ),
                            Visibility(
                              visible: _descricao,
                              child: SafeArea(
                                child: Text(conDescricao),
                              ),
                            ),
                            Visibility(
                              visible: _data,
                              child: Divider(),
                            ),
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: _data,
                                  child: Text(conData),
                                ),
                                Visibility(
                                  visible: _data,
                                  child: Text(conHora),
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

    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference dataRef = firebaseDatabase.reference();

    var dados = dataRef.child("publicacoes").child("curso").child("periodo");

    await dados.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        Publicacao publicacao = Publicacao();
        publicacao.titulo = values["titulo"];
        publicacao.descricao = values["descricao"];
        publicacao.data = values["data"];
        publicacao.hora = values["hora"];

        Usuario usuario = Usuario();
        usuario.nome = values["usuario"]["nome"];
        usuario.email = values["usuario"]["email"];

        publicacao.usuario = usuario;


        listPublicacoes.add(publicacao);
      });
    });

    return listPublicacoes;
  }
}

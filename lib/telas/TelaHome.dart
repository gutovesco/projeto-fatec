import 'package:app_teste/activities/CriarTurma.dart';
import 'package:app_teste/activities/MinhasPublicacoes.dart';
import 'package:app_teste/activities/MinhasTurma.dart';
import 'package:app_teste/activities/Publicar.dart';
import 'package:app_teste/model/Turma.dart';
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
  List<Widget> _listFragments = [HomeHome(), TurmaHome()];
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
        myDrawer();
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
          pesquisarTurmaMenu(),
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
      drawer: myDrawer(),
      body: Center(
        child: _listFragments[_selecionado],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selecionado,
        onTap: (index) {
          if (index == 0) {
            _telaAtual = "Home";
            telaTurma = false;
          } else {
            _telaAtual = "Turma";
            telaTurma = true;
          }
          setState(() {
            _selecionado = index;
            _telaAtual;
            telaTurma;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            title: Text("Turma"),
          )
        ],
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

  FutureBuilder<dynamic> myDrawer() {
    print("Estou aqui");
    if (dadosUsuario == null) {
      return null;
    }
    return FutureBuilder<dynamic>(
      future: usuario,
      builder: (context, snapshot) {
        print("executei");
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.waiting:
            return Container();
            break;
          case ConnectionState.active:
            return null;
            break;
          case ConnectionState.done:
            dadosUsuario = snapshot.data;
            return Drawer(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Publicar(user: dadosUsuario)));
                    },
                    title: Text("Publicar"),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CriarTurma(dadosUsuario)));
                    },
                    title: Text("Criar uma nova turma"),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MinhasTurmas()));
                    },
                    title: Text("Minhas turmas"),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MinhasPublicacoes()));
                    },
                    title: Text("Minhas publicações"),
                  )
                ],
              ),
            );

            break;
        }
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

  Widget pesquisarTurmaMenu() {
    if (telaTurma == true) {
      return IconButton(
        icon: Icon(Icons.search),
        onPressed: () {},
      );
    } else {
      return Container();
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
    return Text("lala");
  }
}

class TurmaHome extends StatefulWidget {
  @override
  _TurmaHomeState createState() => _TurmaHomeState();
}

class _TurmaHomeState extends State<TurmaHome> {
  List<Turma> _listTurma = List();

  Future<List<Turma>> buscarDados() async {
    FirebaseAuth fireAuth = FirebaseAuth.instance;
    FirebaseUser fireUser = await fireAuth.currentUser();
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference dataRef = firebaseDatabase.reference();
    
    List<Turma> listaTurma = List();

    var dados = dataRef.child("usuarios").child(fireUser.uid).child("turmas");

    await dados.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key,values) {
        Turma turma = Turma();
        turma.nomeTurma = values["nomeTurma"];
        turma.periodo = values["periodo"];
        turma.curso = values["curso"];
        turma.modulo = values["modulo"];
        listaTurma.add(turma);
      });
    });
    return listaTurma;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Turma>>(
          future: buscarDados(),
          builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none:
              break;
            case ConnectionState.waiting:
            print("executei");
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
            print(snapshot.data);
              if(snapshot.data == null){
                return Center(
                  child: Text("Não foi possível recuperar os dados!"),
                );
              }else{
                return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, indice){
                  List<Turma> listTurma = snapshot.data;
                  
                  Turma turma = listTurma[indice];

                  return ListTile(
                    title: Text(turma.nomeTurma),
                    subtitle: Text("Curso: ${turma.curso} | Perído: ${turma.periodo} | Módulo: ${turma.modulo}"),
                  );
                },
              );
              }
              break;
          }
        },
      );
  }
}

import 'package:app_teste/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  var _nomeController = TextEditingController();
  var _emailController = TextEditingController();
  var _senhaController = TextEditingController();
  var _confSenhaController = TextEditingController();

  FirebaseAuth fireAuth = FirebaseAuth.instance;

  void iniciarCadastro() {
    String nome = _nomeController.text;
    String email = _emailController.text;
    String senha = _senhaController.text;
    String confSenha = _confSenhaController.text;

    bool verificar = verificarCampos(nome, email, senha, confSenha);

    if (verificar == true) {
      Usuario usuario = Usuario();
      usuario.senha = senha;
      usuario.email = email;
      usuario.nome = nome;
      cadastrarFirebase(usuario);
    }
  }

  bool verificarCampos(String nome, String email, String senha, String confSenha) {
    if (nome.isNotEmpty) {
      if (email.isNotEmpty) {
        if (senha.isNotEmpty) {
          if (confSenha.isNotEmpty) {
            if (senha == confSenha) {
              return true;
            } else {
              msg("Erro! Digite sua senha novamente!");
            }
          } else {
            msg("Campo confirmar senha vazio!");
          }
        } else {
          msg("Campo senha vazio!");
        }
      } else {
        msg("Campo e-mail vazio!");
      }
    } else {
      msg("Campo nome vazio!");
    }
    return false;
  }

  void msg(String msgErro) {
    Toast.show(msgErro, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  void cadastrarFirebase(Usuario usuario) {
    fireAuth.createUserWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha)
      .then(
      (snapshot)async{
        usuario.idUsuario = snapshot.uid;
        usuario.tipoUsuario = "V";
        usuario.cadastrarFireBase();
        
        Navigator.pushNamedAndRemoveUntil(context, "/", (_)=>false);
        
        
      }
    ).catchError(
      (snapshot){
        msg("Ihhhhhhhh");
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Realizando cadastro"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: 320,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        print("teste");
                      },
                      child: Container(
                        height: 120,
                        width: 120,
                        child: CircleAvatar(
                          backgroundImage: ExactAssetImage("imagens/fundo.png"),
                        ),
                      ),
                    ),
                    Text("Clique na foto para adicionar/alterar"),
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                          hintText: "Ex: João",
                          labelText: "Digite o seu nome: "),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: "Ex: joao@hotmail.com",
                          labelText: "Digite o seu e-mail"),
                    ),
                    TextField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: "Ex: J12345(mínimo 6 dígitos)",
                          labelText: "Digite sua senha: "),
                    ),
                    TextField(
                      controller: _confSenhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: "Ex: J12345(mínimo 6 dígitos)",
                          labelText: "Digite novamente sua senha: "),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: RaisedButton(
                        child: Text("Cadastrar"),
                        onPressed: () {
                          iniciarCadastro();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

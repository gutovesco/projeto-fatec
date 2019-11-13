
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Usuario {

  String _imagemPerfil;
  String _email;
  String _senha;
  String _nome;
  String _tipoUsuario;
  String _idUsuario;
  String _curso;
  String _modulo;
  String _periodo;
  String _professorMateria;
  

  Future<bool> cadastrarFireBase()async{

    Map<String, String> dados = Map();
    dados["imagemPerfil"] = imagemPerfil;
    dados["email"] = email;
    dados["nome"] = nome;
    dados["tipoUsuario"] = tipoUsuario;
    dados["idUsuario"] = idUsuario;
    dados["curso"] = curso;

    FirebaseAuth fireAuth = FirebaseAuth.instance;
    FirebaseUser fireUser = await fireAuth.currentUser();
    FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
    DatabaseReference dataRef = firebaseDatabase.reference();

    dataRef.child("usuarios").child(fireUser.uid).child("dadosUsuario").set(
      dados
    );
      
  }

  String get professorMateria => _professorMateria;

  set professorMateria(String professorMateria) {
    _professorMateria = professorMateria;
  }

  String get periodo => _periodo;

  set periodo(String periodo) {
    _periodo = periodo;
  }

  String get modulo => _modulo;

  set modulo(String modulo) {
    _modulo = modulo;
  }

  String get curso => _curso;

  set curso(String curso) {
    _curso = curso;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String idUsuario) {
    _idUsuario = idUsuario;
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String tipoUsuario) {
    _tipoUsuario = tipoUsuario;
  }

  String get nome => _nome;

  set nome(String nome) {
    _nome = nome;
  }

  String get senha => _senha;

  set senha(String senha) {
    _senha = senha;
  }

  String get email => _email;

  set email(String email) {
    _email = email;
  }

  String get imagemPerfil => _imagemPerfil;

  set imagemPerfil(String imagemPerfil) {
    _imagemPerfil = imagemPerfil;
  }

	




}
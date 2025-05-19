import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider extends ChangeNotifier{

  User? user;

  final FirebaseAuth auth = FirebaseAuth.instance;

  String? emaillError;
  String? passwordError;

  String? generalError;

  bool isLoading = false;
  bool isUploaded = false;

  String password = '';
  String email = '';

  void getEmail(String value){
    
    email = value;

    if(email.isEmpty){
      emaillError = 'Correo obligatorio.';
    }else if(!email.contains('@')){
      emaillError = 'Requiere un correo valido';
    }else{
      emaillError = null;
    }
    notifyListeners();
  }

  void getPassword(String value){
    
    password = value;

    if(password.isEmpty){
      passwordError = 'Contraseña obligatorio.';
    }else if(password.length < 6){
      passwordError = 'Minimo 6 digitos';
    }else{
      passwordError = null;
    }
    notifyListeners();
  }

  bool validateTextField(){

    getEmail(email);
    getPassword(password);
    
    return passwordError == null && emaillError == null;
  }

  Future<void> signIn() async{

    generalError = null;

    isLoading = true;
    
    try{

      await auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      userAuthStatus();
      
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user not found') {
        generalError = 'Usuario no encontrado';
      } else if (e.code == 'wrong password') {
        generalError = 'Contraseña incorrecta';
      } else {
        generalError = 'Error: ${e.message}';
      }

    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(String email, String password) async{

    isUploaded = false;
    isLoading = true;

    try{
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      isLoading = false;
      isUploaded = true;
      
    }on FirebaseAuthException catch(e){
      if(e.code == 'invalid-email')
      {
        emaillError = 'Correo electrónico invalido.';
      }else if(e.code == 'email-already-in-use'){
        emaillError = 'Correo ya registrado.';
      }
      
      debugPrint(e.code);
      isLoading = false;
    }

    password = '';
    email = '';
    notifyListeners();
  }

  Future<void> signOut () async{
    auth.signOut();
    userAuthStatus();
    notifyListeners();
  }
  
  void userAuthStatus(){
    FirebaseAuth.instance.authStateChanges().listen((User? usuario) {
      user = usuario;    
      notifyListeners();
    });

  }

  void clearData(){
    emaillError = null;
    passwordError = null;
    generalError = null;

    password = '';
    email = '';
    
    notifyListeners();
  }
}

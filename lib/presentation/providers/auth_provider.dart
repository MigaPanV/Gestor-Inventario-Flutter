import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier{

  User? user;

  final FirebaseAuth auth = FirebaseAuth.instance;
  

  String? emaillError;
  String? passwordError;
  String? generalError;
  bool isLoading = false;

  String password = '';
  String email = '';

  void getEmailError(String value){
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

  void getPasswordError(String value){
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

    getEmailError(email);
    getPasswordError(password);
    return passwordError == null && emaillError == null;
  }

  Future<void> signIn() async{

    generalError = null;
    isLoading = true;
    notifyListeners();
    
    try{

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      user = userCredential.user;
      isLoading = false;
      notifyListeners();
      
    }on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        generalError = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        generalError = 'Contraseña incorrecta';
      } else {
        generalError = 'Error: ${e.message}';
      }

      isLoading = false;
      notifyListeners();

    }
  }

  Future<void> register(String email, String password) async{

    try{
      
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
        );

      user = userCredential.user;

      notifyListeners();
    }catch(e){
      Text('Error al registrarse: $e');
    }
  }

  Future<void> signOut () async{
    auth.signOut();
    user = null;
    notifyListeners();
  }

  //void userAuthStatus(){
  //  user = auth.currentUser;
  //  notifyListeners();
  //}




}
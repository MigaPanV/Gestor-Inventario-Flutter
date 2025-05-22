import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthProvider extends ChangeNotifier{

  User? user;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String role = '';
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
      
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      if(userCredential.user != null){
        String? rol = await getUserRole(userCredential.user!.uid);
        role = rol!;
      }
      userAuthStatus();
      
    }on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'unknown-error') {
        generalError = 'Contraseña o correo incorrecto';
      } else if (e.code == 'network-request-failed') {
        generalError = 'Conexion fallida';
      } 
      else if(e.code == "invalid-email"){
        generalError = 'Datos invalidos';
      }
      else if(email.isEmpty && e.code == 'invalid-email'){
        generalError = null;
        emaillError = 'Ingrese un correo';
      }
      else if(e.code == 'unknown-error'){
        passwordError = 'Contraseña invalida';
      }
      else {
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
      final credentialUser = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      if(credentialUser.user != null ){
        assignUserRole(credentialUser.user!.uid, role, credentialUser.user!.email!);
      }
      isLoading = false;
      isUploaded = true;
      
    }on FirebaseAuthException catch(e){
      if(e.code == 'invalid-email')
      {
        emaillError = 'Correo electrónico invalido.';
      }else if(e.code == 'email-already-in-use'){
        emaillError = 'Correo ya registrado.';
      }else if (e.code == 'network-request-failed') {
        generalError = 'Conexion fallida';
      }
      isLoading = false;
    }

    password = '';
    email = '';
    notifyListeners();
  }

  Future<void> signOut () async{
    auth.signOut();
    role = '';
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

  Future<void> assignUserRole(String uId, String rol, String email) async{
    
      await firestore.collection('Usuarios').doc(uId).set({
        'correo': email,
        'rol': rol
      });
  }

  Future<String?> getUserRole(String uid) async{

      DocumentSnapshot userDoc = await firestore.collection('Usuarios').doc(uid).get();

      if(userDoc.exists){
        return userDoc.get('rol');
      }
      else {
        return null;
      }
  }
}

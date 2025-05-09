import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestor_inventario/firebase_options.dart';

import 'package:gestor_inventario/presentation/screens/auth_page.dart';
import 'package:gestor_inventario/presentation/screens/client_screen/client_page.dart';

import 'package:gestor_inventario/presentation/providers/auth_provider.dart';
import 'package:gestor_inventario/presentation/providers/products_client_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    //final db = FirebaseFirestore.instance;
//
    //final usuario = <String, dynamic>{
    //  "first": "Ada",
    //  "last": "Lovelace",
    //  "born": 1815
    //};
    //db.collection("usuario").add(usuario).then((DocumentReference doc) =>
    //  print('DocumentSnapshot added with ID: ${doc.id}'));

                

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsClientProvider())
        //ChangeNotifierProvider(create: (_) => ProductsProvider())
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {

          return MaterialApp(

            // Add a new document with a generated ID
            
            debugShowCheckedModeBanner: false,
            title: 'Gestor de inventario',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 162, 201, 219)),
            ),
            home:  authProvider.user != null ? ClientPage() : AuthPage(),
          );
        },
        
      ),
    );
  }
}
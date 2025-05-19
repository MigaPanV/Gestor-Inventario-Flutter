import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/firebasefirestore_provider.dart';
import 'package:gestor_inventario/presentation/screens/admin/admin_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:gestor_inventario/firebase_options.dart';

import 'package:gestor_inventario/presentation/screens/auth/auth_screen.dart';
import 'package:gestor_inventario/presentation/screens/client/client_screen.dart';

import 'package:gestor_inventario/presentation/providers/firebaseauth_provider.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsClientProvider()..addToList()),
        ChangeNotifierProvider(create: (_) => FirebasefirestoreProvider())
      ],
      child: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {

          return MaterialApp(
            
            debugShowCheckedModeBanner: false,
            title: 'Gestor de inventario',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 162, 201, 219)),
            ),
            home: authProvider.user == null 
            ? AuthScreen() 
            : authProvider.user != null && authProvider.role == 'Cliente' ? ClientScreen() : AdminHomeScreen(),
          );
        },
      ),
    );
  }
}
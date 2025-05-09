
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          CircularProgressIndicator(),
          Text('Verificando Datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),)
        ]),
      ),
    );
  }
}
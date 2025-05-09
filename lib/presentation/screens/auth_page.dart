import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/auth_provider.dart';
import 'package:gestor_inventario/presentation/screens/client_screen/client_page.dart';
import 'package:gestor_inventario/presentation/screens/loading_page.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);

    if(authProvider.isLoading){
      return const LoadingPage();
    }
    if(authProvider.user != null){
      return const ClientPage();
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints( maxWidth: 600, maxHeight: 600),

          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.all(Radius.circular(10))),
          
              child: Column(
                
                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [
                  
                  Text('Iniciar sesion', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),

                  if(authProvider.generalError != null)
                    Text(authProvider.generalError!, style: TextStyle(color: Colors.red )),
                  
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(

                      onChanged: (value) {
                        authProvider.getEmailError(value);
                      },
                      
                      decoration: InputDecoration(
                        labelText: 'Correo',
                        errorText: authProvider.emaillError),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(

                      onChanged: (value) {
                        authProvider.getPasswordError(value);
                      },

                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text(
                          'Password'),
                        errorText: authProvider.passwordError),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async{

                      if(authProvider.validateTextField()){
                        await authProvider.signIn();
                      }
                      
                    }, 
                    child: Text(
                      'Iniciar sesion'
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
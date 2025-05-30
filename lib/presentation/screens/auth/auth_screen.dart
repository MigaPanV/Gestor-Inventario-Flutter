import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/firebaseauth_provider.dart';
import 'package:gestor_inventario/presentation/screens/client/client_screen.dart';
import 'package:gestor_inventario/presentation/screens/auth/loading_screen.dart';
import 'package:gestor_inventario/presentation/screens/register/register_screen.dart';
import 'package:gestor_inventario/presentation/widgets/shared/custom_text_field.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<FirebaseAuthProvider>(context); //context.watch<AuthProvider>();

    if(authProvider.isLoading){
      return const LoadingScreen(text: 'Verificando datos',);
    }
    if(authProvider.user != null){
      return const ClientScreen();
    }
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints( maxWidth: 600, maxHeight: 600),
                  
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
              
                  child: Column(
                    
                    mainAxisAlignment: MainAxisAlignment.center,
                    
                    children: [
                      
                      Text('Iniciar sesion', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                  
                      if(authProvider.generalError != null)
                        Text(authProvider.generalError!, style: TextStyle(color: Colors.red )),
                      
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            CustomTextField(
                              labeltext: 'Correo',
                              onChanged: authProvider.getEmail, 
                              errorText: authProvider.emaillError
                            ),
                  
                            SizedBox(height: 24),
                  
                            CustomTextField(
                              labeltext: 'Constraseña',
                              onChanged: authProvider.getPassword, 
                              errorText: authProvider.passwordError,
                              obscureText: true
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async{
                          if(authProvider.validateTextField()){
                            await authProvider.signIn();

                            authProvider.email = '';
                            authProvider.password = '';
                          }
                        }, 
                        child: Text(
                          'Iniciar sesion'
                        ),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          authProvider.clearData();
                          authProvider.role = 'Cliente';
                          Navigator.push(context, MaterialPageRoute<void>(
                          builder: (BuildContext context) => const RegisterScreen()));
                          
                        },
                        child: Text('Registrarse', style: TextStyle(color: Colors.blue)),
                      )
                    ],
                      
                  ),
                ),
              ),
            ),
          ),
        ),
        
      ),
    );
  }
}

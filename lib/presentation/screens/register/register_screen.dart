import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/firebaseauth_provider.dart';
import 'package:gestor_inventario/presentation/screens/auth/loading_screen.dart';
import 'package:gestor_inventario/presentation/widgets/shared/custom_text_field.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {

    //TODO mejorar la captura de errores

    final registerProvider = context.watch<FirebaseAuthProvider>();
    
    if(registerProvider.isLoading){

      return LoadingScreen(text: 'Añadiendo datos');

    }

    if(!registerProvider.isLoading && registerProvider.isUploaded){

      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Datos cargados', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                  ],
                ),
                ElevatedButton(
                  onPressed: (){
        
                    registerProvider.clearData();
                    
                    Navigator.pop(context);
                    registerProvider.isUploaded = false;
                  }, 
                  child: Text('Continuar')
                )
              ],
            )
            
          )
        ),
      );
    }
    return SafeArea(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints( maxWidth: 600, maxHeight: 600),
                child: Stack(
                  children: [
                    
                    Positioned(
                    
                      left: 5,
                      top: 60,
                    
                      child: IconButton(
                        tooltip: 'Regresar',
                    
                        onPressed: (){
                          Navigator.pop(context);
                          registerProvider.clearData();
                        }, 
                        icon: Icon(Icons.arrow_back)
                      )                  
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(width: 1), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                        
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                            Text('Registro', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
                    
                            if(registerProvider.generalError != null)
                              Text(registerProvider.generalError!, style: TextStyle(color: Colors.red )),
                          
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  CustomTextField(
                                    labeltext: 'Correo',
                                    onChanged: registerProvider.getEmail, 
                                    errorText: registerProvider.emaillError
                                  
                                  ),
                                  SizedBox(height: 24),
                    
                                  CustomTextField(
                                    labeltext: 'Contraseña',
                                    onChanged: registerProvider.getPassword, 
                                    errorText: registerProvider.passwordError, 
                                    obscureText: true
                                  )
                                ],
                              ),
                            ),
                    
                            ElevatedButton(
                              onPressed: ()async{
                    
                                if(registerProvider.validateTextField()){
                                  await registerProvider.register(registerProvider.email, registerProvider.password);
                                  await registerProvider.signOut();
                                }
                                
                              },
                              child: Text('Registrarse')
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      
      ),
    );
  }
}
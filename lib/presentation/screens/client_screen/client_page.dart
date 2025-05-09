import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/products_client_provider.dart';
import 'package:gestor_inventario/presentation/screens/client_screen/client_cart.dart';
import 'package:gestor_inventario/presentation/screens/client_screen/client_home.dart';
import 'package:gestor_inventario/presentation/screens/client_screen/client_sign_out.dart';
import 'package:provider/provider.dart';

class ClientPage extends StatelessWidget {
  const ClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final changeIndex = context.watch<ProductsClientProvider>();

    int selectedIndex = changeIndex.selectedIndex;

    Widget page;

    switch(selectedIndex){
      case 0: 
        page = ClientHome();
        break;
      case 1: 
        page = ClientCart();
        break;
      case 2:
        page = ClientSignOut();
        break;
          default:
        throw UnimplementedError('no widget for $selectedIndex');
        }

    return LayoutBuilder(
      builder: (context, constraints){
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(

                extended: constraints.maxWidth >= 900, 
                
                destinations: [
                  
                  NavigationRailDestination(
                    icon: Icon(Icons.home), 
                    label: Text('Inicio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400))),
                      
                  NavigationRailDestination(
                    icon: Icon(Icons.shopping_cart), 
                    label: Text('Carrito', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400))),
                      
                  NavigationRailDestination(
                    icon: Icon(Icons.door_back_door_outlined), 
                    label: Text('Cerrar sesion', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)))],
                selectedIndex: selectedIndex,

                onDestinationSelected: (value) {

                  changeIndex.changeIndex(value);
                  
                },
              ),
                
                
            ),
            VerticalDivider( 
              width: 1,
              thickness: 1,
              color: Colors.grey,
            ),
            Expanded(
              child: Container(
                child: page
              )
            )
          ],
        );
      }
    );
  }
}
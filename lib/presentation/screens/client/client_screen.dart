import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:gestor_inventario/presentation/screens/client/pages/client_cart_page.dart';
import 'package:gestor_inventario/presentation/screens/client/pages/client_home_page.dart';
import 'package:provider/provider.dart';

class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final TextStyle style = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
    final clientProvider = context.watch<ProductsClientProvider>();

    int selectedIndex = clientProvider.selectedIndex;

    Widget page;

    switch(selectedIndex){
      case 0: 
        page = ClientHomePage();
        break;
      case 1:
        page = ClientCartPage();
        break;
      default:
        page = ClientHomePage();
    }

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints){
          return Row(
            children: [
              NavigationRail(
                
                extended: constraints.maxWidth >= 900, 
                
                destinations: [
                  _customNavigationRail(style: style, icon: Icons.home, text: 'Inicio'),
                  _customNavigationRail(style: style, icon: Icons.shopping_cart, text: 'Carrito'),
                  _customNavigationRail(style: style, icon: Icons.door_back_door_outlined, text: 'Cerrar sesión')
                ],
                
                selectedIndex: selectedIndex > 1 ? 0 : selectedIndex,
                
                onDestinationSelected: (index) {
                  if(index == 2){
                    WidgetsBinding.instance.addPostFrameCallback((_) => clientProvider.openDialogSignout(context));                    
                  }
                  else{
                    clientProvider.changeIndex(index);
                  }
                  
                },
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
      ),
    );
  }

  NavigationRailDestination _customNavigationRail({
    required TextStyle style, 
    required IconData icon, 
    required String text
  }){
    return NavigationRailDestination(
      icon: Icon(icon), 
      label: Text(text, style: style));
  }
}
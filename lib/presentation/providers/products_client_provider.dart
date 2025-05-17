
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/presentation/providers/firebase_provider.dart';
import 'package:provider/provider.dart';

class ProductsClientProvider extends ChangeNotifier{

  List<Product> listProduct = [
    Product(
      nameProduct: 'Mouse HyperX', 
      descriptionProduct: 'Especial para juegos FPS', 
      priceProduct: 200000, 
      stockProduct: 5, 
      imageurl: 'https://panamericana.vtexassets.com/arquivos/ids/445437/mouse-alambrico-pulsefire-core-hyperx-negro-2-196188043127.jpg?v=637927434974870000',
      ),
      
    Product(
      nameProduct: 'Teclado Redragon Fizz Pro', 
      descriptionProduct: 'formato 60%', 
      priceProduct: 250000,
      stockProduct: 10, 
      imageurl: 'https://www.mipcparquecentral.com/cdn/shop/files/RedragonfizzProBlancoGris.jpg?v=1734467300',
      ),

    Product(
      nameProduct: 'Monitor HyperX', 
      descriptionProduct: '144 Hz', 
      priceProduct: 480000,
      stockProduct: 2, 
      imageurl: 'https://row.hyperx.com/cdn/shop/products/hyperx_armada_27_qhd_gaming_monitor_g_sync_1_main.jpg?v=1662579184',
      ),
  ];

  List<Product> listCart = [];

  int selectedIndex = 0;

  void addCart(Product product){

    listCart.add(product);
    notifyListeners();

  }

  void changeIndex(index){
    selectedIndex = index; 
    notifyListeners();
  }

  void deleteCart(Product product){
    listCart.remove(product);
    notifyListeners();
  }

  void updateCart(){
    notifyListeners();
  }

  void openDialogSignout(BuildContext context){

    final firebase = context.read<FirebaseProvider>();

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (context) => AlertDialog(

        content: Text('¿Desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            }, 
            child: Text('Cancelar')),

          FilledButton(
            onPressed: (){
              firebase.signOut();
              Navigator.of(context).pop();
              firebase.clearData();
              selectedIndex = 0;
            }, 
            child: Text('Aceptar'))
        ],

      )

    );

    notifyListeners();
  }







}
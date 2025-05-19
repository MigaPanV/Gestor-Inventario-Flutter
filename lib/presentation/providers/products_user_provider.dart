
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/presentation/providers/firebaseauth_provider.dart';
import 'package:gestor_inventario/presentation/providers/firebasefirestore_provider.dart';
import 'package:gestor_inventario/presentation/widgets/shared/custom_text_field.dart';
import 'package:provider/provider.dart';

class ProductsClientProvider extends ChangeNotifier{

  List<Product> listProduct = [
  //  Product(
  //    nameProduct: 'Mouse HyperX', 
  //    descriptionProduct: 'Especial para juegos FPS', 
  //    priceProduct: 200000, 
  //    stockProduct: 5, 
  //    imageurl: 'https://panamericana.vtexassets.com/arquivos/ids/445437/mouse-alambrico-pulsefire-core-hyperx-negro-2-196188043127.jpg?v=637927434974870000',
  //    ),
  //    
  //  Product(
  //    nameProduct: 'Teclado Redragon Fizz Pro', 
  //    descriptionProduct: 'formato 60%', 
  //    priceProduct: 250000,
  //    stockProduct: 10, 
  //    imageurl: 'https://www.mipcparquecentral.com/cdn/shop/files/RedragonfizzProBlancoGris.jpg?v=1734467300',
  //    ),
//
  //  Product(
  //    nameProduct: 'Monitor HyperX', 
  //    descriptionProduct: '144 Hz', 
  //    priceProduct: 480000,
  //    stockProduct: 2, 
  //    imageurl: 'https://row.hyperx.com/cdn/shop/products/hyperx_armada_27_qhd_gaming_monitor_g_sync_1_main.jpg?v=1662579184',
  //    ),
  ];

  List<Product> listCart = [];

  int selectedIndex = 0;
  
  Future<void> addToList() async{

    
    final newProducts = await FirebasefirestoreProvider().getProducts();

    final uniqueProducts = newProducts.where((newProduct) {
      return !listProduct.any((existingProduct) => existingProduct.nameProduct == newProduct.nameProduct);
    }).toList();

    if (uniqueProducts.isNotEmpty) {
      listProduct.addAll(uniqueProducts);
      notifyListeners();
    }
  }

  Future<void> deleteToList(Product product) async {
    listProduct.removeWhere((p) => p.nameProduct == product.nameProduct);
    debugPrint('$listProduct');
    notifyListeners();
  }

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

  void openDialogAddProduct(BuildContext context) {

    final rootContext = context;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        
        return Consumer<FirebasefirestoreProvider>(
          builder: (context, firestore, _) {
            return StatefulBuilder(
              builder: (context, setState){

                if (firestore.isLoading) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('Añadiendo datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  );
                }

                if (!firestore.isLoading && firestore.isUploaded) {
                  final productProvider = context.read<ProductsClientProvider>();
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Datos cargados',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle, color: Colors.green, size: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          firestore.clearData();
                          firestore.isUploaded = false;
                          productProvider.addToList();
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Continuar'),
                      )
                    ],
                  ),
                );
              }
                return AlertDialog(
                  title: Text('Añadir producto'),
                  
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextField(
                          onChanged: firestore.getName,
                          errorText: firestore.errorgeneral,
                          labeltext: 'Nombre del producto',
                        ),
                        CustomTextField(
                          onChanged: firestore.getDescription,
                          errorText: firestore.errorgeneral,
                          labeltext: 'Descripción del producto',
                        ),
                        CustomTextField(
                          onChanged: firestore.getPrice,
                          errorText: null,
                          labeltext: 'Precio del producto',
                        ),
                        CustomTextField(
                          onChanged: firestore.getStock,
                          errorText: null,
                          labeltext: 'Stock del producto',
                        ),
                        SizedBox(height: 20),
                        FilledButton(
                          onPressed: ()async{
                            await firestore.getImage();
                          }, 
                          child: Text('Cargar foto')
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(rootContext);
                      },
                      child: Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () async {

                        if(firestore.imageToUpload == null){
                            debugPrint('path: ${firestore.imageToUpload}');
                            return;
                        } 
                        
                        if (firestore.validateTextField()) {
                          firestore.setLoading(true);
                          await firestore.uploadImage();
                          await firestore.addProduct();
                          
                          
                          firestore.setLoading(false);
                          firestore.setUploaded(true);
                        }
                      },
                      child: Text('Añadir'),
                    ),
                  ],
                );
              }
            );
          },
        );
      },
    );
    notifyListeners();
  }

  void openDeleteProduct(BuildContext context, Product product){

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (dialogcontext) {
        return Consumer<FirebasefirestoreProvider>(
          builder: (context, firestore, _) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              content: Text('¿Desea eliminar este articulo?'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(dialogcontext);
                  }, 
                  child: Text('Cancelar')),
                FilledButton(
                  onPressed: (){
                    firestore.deleteProduct(dialogcontext, product);
                    Navigator.pop(dialogcontext);
                  }, 
                  child: Text('Eliminar'))
              ],
            ),
          ),
        );
      });
  }

  void openDialogSignout(BuildContext context){

    final firebase = context.read<FirebaseAuthProvider>();

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
            child: Text('Aceptar')
          )
        ],
      )
    );
    notifyListeners();
  }

}
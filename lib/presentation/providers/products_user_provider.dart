import 'package:cloud_firestore/cloud_firestore.dart';
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
      return !listProduct.any((existingProduct) => existingProduct.sku == newProduct.sku);
    }).toList();

    if (uniqueProducts.isNotEmpty) {
      listProduct.addAll(uniqueProducts);
      notifyListeners();
    }
  }

  Future<void> deleteToList(Product product) async {
    listProduct.removeWhere((p) => p.sku == product.sku);
    notifyListeners();
  }

  Future<void> updateList() async{
    
    try{
      final updatedproducts = await FirebasefirestoreProvider().getProducts();
      listProduct = updatedproducts;
      notifyListeners();

    } on FirebaseException catch (e){
      debugPrint("Error al obtener productos: $e");
    }

  }

  void addCart(Product product){
    listCart.add(product);
    notifyListeners();
  }

  void changeIndex(index) {
    selectedIndex = index;
    notifyListeners();
  }

  void deleteCart(Product product) {
    listCart.remove(product);
    notifyListeners();
  }

  void updateCart() {
    notifyListeners();
  }

  void openDialogAddProduct(BuildContext context) {
    final rootContext = context;
    String? generalerror = '';
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return Consumer<FirebasefirestoreProvider>(
          builder: (context, firestore, _) {
            return StatefulBuilder(builder: (context, setState) {
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
                        child: Text('Añadiendo datos',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
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
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          firestore.clearData();
                          firestore.setUploaded(false);
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
                title: Column(
                  children: [
                    Text('Añadir producto'),
                    Text('$generalerror', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w400),)
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        onChanged: firestore.getName,
                        errorText: firestore.errorName,
                        labeltext: 'Nombre del producto',
                      ),
                      CustomTextField(
                        onChanged: firestore.getDescription,
                        errorText: firestore.errorDescription,
                        labeltext: 'Descripción del producto',
                      ),
                      CustomTextField(
                        onChanged: firestore.getPrice,
                        errorText: firestore.errorPrice,
                        labeltext: 'Precio del producto',
                      ),
                      CustomTextField(
                        onChanged: firestore.getStock,
                        errorText: firestore.errorStock,
                        labeltext: 'Stock del producto',
                      ),
                      SizedBox(height: 20),
                      FilledButton(
                          onPressed: () async {
                            await firestore.getImage();
                            debugPrint('${firestore.imageToUpload}');
                          },
                          child: Text('Cargar foto')),
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
                      final isValid = firestore.validateTextField();
                      if (firestore.imageToUpload == null){
                        generalerror = 'No hay imagen';
                        return;
                      }
                      if (!isValid) return;

                      firestore.setLoading(true);
                      await firestore.uploadImage();
                      firestore.generateSKU(firestore.nameProduct);
                      await firestore.addProduct();
                      firestore.setLoading(false);
                      firestore.setUploaded(true);
                    },
                    child: Text('Añadir'),
                  ),
                ],
              );
            });

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
      builder: (dialogContext) {

        
        return Consumer<FirebasefirestoreProvider>(
          builder: (context, firestore, _) => StatefulBuilder(
            builder: (context, setState)  {

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
                          child: Text('Eliminando datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  );
                }

                if (!firestore.isLoading && firestore.isUploaded) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Datos eliminados',
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
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Continuar'),
                      )
                    ],
                  ),
                );
              }
              return AlertDialog(
                content: Text('¿Desea eliminar este articulo?'),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.pop(dialogContext);
                    }, 
                    child: Text('Cancelar')),
                  FilledButton(
                    onPressed: () async{
                      firestore.setLoading(true);
                      await firestore.deleteProduct(dialogContext, product);
                      firestore.setLoading(false);
                      firestore.setUploaded(true);
                    }, 
                    child: Text('Eliminar'))
                ],
              );
            }
          ),
        );
      });
  }

  void openUpdateProduct(BuildContext context, Product product){

    final nameController = TextEditingController(text: product.nameProduct);
    final descriptionController = TextEditingController(text: product.descriptionProduct);
    final priceController = TextEditingController(text: product.priceProduct.toString());
    final stockController = TextEditingController(text: product.stockProduct.toString());

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (dialogContext) => Consumer<FirebasefirestoreProvider>(
        builder: (context, firestore, _) { 
          return StatefulBuilder(
          builder: (context, setState) { 

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
                          child: Text('Actualizando datos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  );
                }

                if (!firestore.isLoading && firestore.isUploaded) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Datos actualizados',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle, color: Colors.green, size: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          
                          firestore.isUploaded = false;
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Continuar'),
                      )
                    ],
                  ),
                );
              }

            return AlertDialog(
            
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  onChanged: firestore.getNewName,
                  errorText: null,
                  labeltext: 'Nombre del producto',
                  controller: nameController,
                ),
                CustomTextField(
                  onChanged: firestore.getNewDescription,
                  errorText: null,
                  labeltext: 'Descripción del producto',
                  controller: descriptionController,

                ),
                CustomTextField(
                  onChanged: firestore.getnewprice,
                  errorText: null,
                  labeltext: 'Precio del producto',
                  controller: priceController,
                ),
                CustomTextField(
                  onChanged: firestore.getNewStock,
                  errorText: null,
                  labeltext: 'Stock del producto',
                  controller: stockController,
                ),
                SizedBox(height: 20),
                FilledButton(
                  onPressed: ()async{
                    await firestore.getImage(); 
                  }, 
                  child: Text('Actualizar foto')
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  
                  firestore.setLoading(true);

                  if(firestore.imageToUpload == null) {
                    firestore.imageurl = product.imageurl;
                  }else{
                    await firestore.uploadImage();
                  }

                  firestore.getName(nameController.text);
                  firestore.getDescription(descriptionController.text);
                  firestore.getStock(stockController.text);
                  firestore.getPrice(priceController.text);

                  await firestore.setProduct(dialogContext, product);
                      
                  firestore.setLoading(false);
                  firestore.setUploaded(true);
                    
                  
                },
                child: Text('Actualizar'),
              ),
            ],

          );}
        );
        }
      )
    );
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar')),
          FilledButton(
              onPressed: () async{
                await firebase.signOut();
                Navigator.of(context).pop();
                firebase.clearData();
                selectedIndex = 0;
              },
              child: Text('Aceptar'))
        ],
      ),
    );
    notifyListeners();
  }
}
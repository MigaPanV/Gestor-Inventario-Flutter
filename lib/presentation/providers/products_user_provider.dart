import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/presentation/providers/firebaseauth_provider.dart';
import 'package:gestor_inventario/presentation/providers/firebasefirestore_provider.dart';
import 'package:gestor_inventario/presentation/widgets/shared/custom_text_field.dart';
import 'package:provider/provider.dart';

class ProductsUserProvider extends ChangeNotifier{

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

    final updatedproducts = await FirebasefirestoreProvider().getProducts();
    listProduct = updatedproducts;
    notifyListeners();

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
  String? generalError = '';
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
              final productProvider = context.read<ProductsUserProvider>();
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
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                  Text('Añadir producto', style: TextStyle(fontWeight: FontWeight.w500)),
                  if (generalError.isNotEmpty)
                    Text(
                      generalError,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  if (firestore.errorImage != null)
                    Text(
                      firestore.errorImage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400
                      ),
                    ),
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
                        setState(() {});
                      },
                      child: Text('Cargar foto')
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
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
                    if (!isValid) {
                      setState(() {});
                      return;
                    }

                    firestore.setLoading(true);
                    await firestore.uploadImage();
                    firestore.generateSKU(firestore.nameProduct);
                    await firestore.addProduct();
                    firestore.setLoading(false);
                    firestore.setUploaded(true);
                    setState(() {});
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                title: Text('¿Desea eliminar este articulo?', style: TextStyle(fontWeight: FontWeight.w500)),
                actionsAlignment: MainAxisAlignment.center,
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
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                title: Text('Editar producto', style: TextStyle(fontWeight: FontWeight.w500)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        onChanged: firestore.getNewName,
                        errorText: firestore.errorName,
                        labeltext: 'Nombre del producto',
                        controller: nameController,
                      ),
                      CustomTextField(
                        onChanged: firestore.getNewDescription,
                        errorText: firestore.errorDescription,
                        labeltext: 'Descripción del producto',
                        controller: descriptionController,
                  
                      ),
                      CustomTextField(
                        onChanged: firestore.getnewprice,
                        errorText: firestore.errorPrice,
                        labeltext: 'Precio del producto',
                        controller: priceController,
                      ),
                      CustomTextField(
                        onChanged: firestore.getNewStock,
                        errorText: firestore.errorStock,
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
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final name = nameController.text;
                      final description = descriptionController.text;
                      final price = priceController.text;
                      final stock = stockController.text;

                      final isValid = firestore.validateUpdateFields(
                        name: name,
                        description: description,
                        price: price,
                        stock: stock,
                      );

                      if (!isValid) {
                        setState(() {});
                        return;
                      }
                      firestore.setLoading(true);
                      if (firestore.imageToUpload == null) {
                        firestore.imageurl = product.imageurl;
                      } else {
                        await firestore.uploadImage();
                      }

                      firestore.getName(name);
                      firestore.getDescription(description);
                      firestore.getStock(stock);
                      firestore.getPrice(price);

                      if(dialogContext.mounted){
                        await firestore.setProduct(dialogContext, product);
                      }
                      firestore.setLoading(false);
                      firestore.setUploaded(true);
                    },
                    child: Text('Actualizar'),
                  ),
                ],
              );
            }
          );
        }
      )
    );
  }

  void openDialogSignout(BuildContext context){

    final firebase = context.read<FirebasefirestoreProvider>();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => Consumer<FirebaseAuthProvider>(
        builder: (context, auth, _) {
          return StatefulBuilder(
            builder: (context, snapshot) {

              if (firebase.isLoading) {
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
                        child: Text('Cerrando sesión', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                );
              }
              if (!firebase.isLoading && firebase.isUploaded) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sesión cerrada',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle, color: Colors.green, size: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          
                          firebase.isUploaded = false;
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Continuar'),
                      )
                    ],
                  ),
                );
              }
              return AlertDialog(
                title: Text('¿Desea cerrar sesión?', style: TextStyle(fontWeight: FontWeight.w500)),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: Text('Cancelar')
                  ),
                  FilledButton(
                    onPressed: () async{
                      
                      firebase.setLoading(true);
                      for(var cart in listCart){
                        cart.cantidadAgregada = 0;
                      }
                      await updateList();
                      clearCart();
                      await auth.signOut();

                      auth.clearData();
                      selectedIndex = 0;
                      firebase.setLoading(false);
                      firebase.setUploaded(true);
                    },
                    child: Text('Aceptar')
                  )
                ],
              );
            }
          );
          
        },
      )
    );
    notifyListeners();
  }

  void openAddAdmin(BuildContext context){

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (dialogContext) {
        return Consumer<FirebaseAuthProvider> (
          builder: (context, auth, _) {
            return StatefulBuilder(
              builder: (context, setState) {

                if (auth.isLoading) {
                  return AlertDialog(
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('Agregando administrador', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  );
                }

                if (!auth.isLoading && auth.isUploaded) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Administrador agregado',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle, color: Colors.green, size: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          
                          auth.isUploaded = false;
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Continuar'),
                      )
                    ],
                  ),
                );
              }
                return AlertDialog(
                  title: Text('Registrar administrador', style: TextStyle(fontWeight: FontWeight.w500)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        errorText: auth.emaillError,
                        onChanged: auth.getEmail,
                        labeltext: 'Correo'
                      ),
                      CustomTextField(
                        errorText: auth.passwordError,
                        onChanged: auth.getPassword,
                        obscureText: true,
                        labeltext: 'Contraseña'
                      )
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(dialogContext);
                      }, 
                      child: Text('Cancelar')
                    ),
                    FilledButton(
                      onPressed: () async{
                        if(auth.validateTextField()){
                          auth.role = 'Administrador';
                          await auth.register(auth.email, auth.password);
                          auth.email = '';
                          auth.password = '';
                        }
                        
                      }, 
                      child: Text('Registrar')
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
    notifyListeners();
  }

  void openInfoCount(BuildContext context){
    showDialog(
      context: context, 
      builder: (dialogContext) => Consumer<FirebaseAuthProvider>(
        builder: (context, auth, _) => AlertDialog(
          title: Text('Informacion de cuenta', style: TextStyle(fontWeight: FontWeight.w500)),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Correo: ${auth.user!.email}')
            ],
          ),
        )
      )
    );
  }
  void openCheckOut(BuildContext context){

    showDialog(barrierDismissible: false,
      context: context, 
      builder: (dialogContext) {
        return Consumer<FirebasefirestoreProvider>(
          builder: (context, firestore, _) {
            return StatefulBuilder(
              builder: (context, setState) {
                if(firestore.isLoading){
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
                          child: Text('Procesando compra', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  );
                }
                if(firestore.ispurchased && !firestore.isLoading){
                  return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Compra finalizada',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle, color: Colors.green, size: 40),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          firestore.ispurchased = false;
                          Navigator.pop(dialogContext);
                        },
                        child: Text('Continuar'),
                      )
                    ],
                  ),
                );

                }
                return AlertDialog(

                  title: Text('Desea finalizar la compra', style: TextStyle(fontWeight: FontWeight.w500),),

                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(dialogContext);
                      }, 
                      child: Text('Cancelar')
                    ),
                    FilledButton(
                      onPressed: () async{
                        firestore.setLoading(true);

                        for(var cart in listCart){

                          await firestore.updateStockAfterPurchase(cart.sku, cart.cantidadAgregada);
                          cart.cantidadAgregada = 0;

                        }
                        clearCart();
                        firestore.setLoading(false);
                      }, 
                      child: Text('Continuar')
                    )
                  ]
                );
              },
            );
          },
        );
      },
    );
    notifyListeners();
  }

  void clearCart(){
    listCart.clear();
    notifyListeners();
  }

  void refresh(BuildContext context){

    showDialog(barrierDismissible: false,
      context: context, 
      builder: (context) => AlertDialog(
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
        )
      )
    );
  }
}
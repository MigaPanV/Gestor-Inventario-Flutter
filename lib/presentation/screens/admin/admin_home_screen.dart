import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/firebaseauth_provider.dart';
import 'package:gestor_inventario/presentation/providers/firebasefirestore_provider.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final productProvider = context.watch<ProductsClientProvider>();
    final firestoreProvider = context.watch<FirebasefirestoreProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
      leading: IconButton(
        onPressed: () {
          
          productProvider.openDialogSignout(context);

        },
        icon: Icon(Icons.door_back_door_outlined),
      ),
      centerTitle: true,
      title: Text(
        'Inventario',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: productProvider.listProduct.isEmpty ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text('No hay productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                      ),
            ],
          ):
          Column(
            children: [
              Expanded(
                child: GridView.builder(

                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(

                    maxCrossAxisExtent: 250,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,

                  ),
                  itemCount: productProvider.listProduct.length,
                  itemBuilder: (context, index){
                    final product = productProvider.listProduct[index];

                    return Card(
                      elevation: 10,
                      clipBehavior: Clip.antiAlias,
                      color: product.stockProduct == 0 ? Colors.red[100] : null,
                      
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Expanded(
                            child: Image.network(

                              product.imageurl,
                              fit: BoxFit.cover,
                              width: double.infinity,

                              loadingBuilder: (context, child, loadingProgress) {

                                if(loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            ),
                          ),
                          
                          SizedBox(height: 5),

                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    product.nameProduct, 
                                    style: TextStyle(   
                                      fontWeight: FontWeight.bold, 
                                      overflow: TextOverflow.ellipsis
                                    ),
                                    maxLines: 2
                                  ),
                                ),
                              ),

                              IconButton(
                                onPressed: () {
                                  productProvider.openUpdateProduct(context, product);
                                  
                                },
                                icon: Icon(Icons.edit)),
                              SizedBox(width: 10)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [ 
                                
                                Row(
                                  children: [
                                    Expanded(child: Text('\$${product.priceProduct}')),
                                    IconButton(
                                    onPressed: () {
                                      productProvider.openDeleteProduct(context, product);
                                    },
                                    icon: Icon(Icons.delete)),
                                    SizedBox(width: 2)
                                  ],
                                ),
                                Text('Stock: ${product.stockProduct}')
                              ],
                            ),
                          ),

                          SizedBox(height: 10),
                          
                        ],
                      ),
                    );
                  },
                ) 
              ),
            ],
          ) ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            firestoreProvider.clearData();
            productProvider.openDialogAddProduct(context);
        },
        child: Icon(Icons.add),
        ),
      )
    );
  }
}
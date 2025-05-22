import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/firebasefirestore_provider.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:provider/provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final productProvider = context.watch<ProductsUserProvider>();
    final firestoreProvider = context.watch<FirebasefirestoreProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              
              productProvider.openDialogSignout(context);

            },
            icon: Icon(Icons.door_back_door_outlined),
          ),
          centerTitle: true,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Inventario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                tooltip: 'Cuenta',
                onPressed: ()async{
                
                  firestoreProvider.setLoading(true);
                  if(firestoreProvider.isLoading){
                    productProvider.refresh(context);
                    await productProvider.updateList();
                  }

                  firestoreProvider.setLoading(false);
                  if(!firestoreProvider.isLoading){ 
                    if(context.mounted){
                      Navigator.pop(context);
                    }
                  }
                }, 
                icon: Icon(Icons.refresh)
              ),
              //IconButton(
              //  tooltip: 'Cuenta',
              //  onPressed: (){
              //    productProvider.openInfoCount(context);
              //  }, 
              //  icon: Icon(Icons.account_circle_outlined)
              //),
              IconButton(
                tooltip: 'Añadir adminsitrador',
                onPressed: (){
                  productProvider.openAddAdmin(context);
                }, 
                icon: Icon(Icons.supervised_user_circle_outlined))
            ],
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
                      
                      child: Stack(
                        children: [
                          Column(
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
                          
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Text(
                                  product.nameProduct,
                                  style: TextStyle( 
                                    fontWeight: FontWeight.bold, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  maxLines: 2
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                child: Text('\$${product.priceProduct}'),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                child: Text('Stock: ${product.stockProduct}'),
                              ),
                            ],
                          ),

                          Positioned(
                            bottom: 50,
                            right: 10,
                            child: IconButton(
                              tooltip: 'Editar producto',
                              onPressed: () {
                                final provider = context.read<FirebasefirestoreProvider>();
                                provider.loadProductToEdit(product);
                                productProvider.openUpdateProduct(context, product);
                              },
                              icon: Icon(Icons.edit)
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IconButton(
                              tooltip: 'Eliminar producto',
                              onPressed: () {
                                productProvider.openDeleteProduct(context, product);
                              },
                              icon: Icon(Icons.delete)
                            ),
                          ),
                        ]
                      ),
                    );
                  },
                ) 
              ),
            ],
          ) 
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Añadir producto',
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
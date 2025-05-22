import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/firebasefirestore_provider.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:provider/provider.dart';

class ClientCartPage extends StatelessWidget {
  const ClientCartPage({super.key});

  @override
  Widget build(BuildContext context) {

    //TODO mejora de la vision de los precios y añadir un snackbar al precionar el boton y no hayan productos en stock

    final productCartProvider = context.watch<ProductsUserProvider>();
    
    if(productCartProvider.listCart.isEmpty){
      return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                  centerTitle: true,
                  title: Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                ),

                Expanded(
                  child: Center(
                    child: Text('No hay productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        )
      );
    }
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Expanded(
                child: GridView.builder(

                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(

                    maxCrossAxisExtent: 250,
                    childAspectRatio: 3 / 4, 
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,

                  ),
                  itemCount: productCartProvider.listCart.length,
                  itemBuilder: (context, index){
                    final product = productCartProvider.listCart[index];

                    return Card(
                      elevation: 10,
                      clipBehavior: Clip.antiAlias,
                      
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
                                    tooltip: 'Eliminar todo',
                                    onPressed: (){

                                      productCartProvider.deleteCart(product);
                                      product.stockProduct += product.cantidadAgregada;
                                      product.cantidadAgregada = 0;
                                    },
                                    icon: Icon(Icons.delete)
                                  ),
                                  SizedBox(width: 5)
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('\$${product.priceProduct * product.cantidadAgregada}'),
                                    Text('Cantidad: ${product.cantidadAgregada}')
                                  ],
                                ),
                              ),
                              
                              SizedBox(height: 10),
                            ],
                          ),
                          Positioned(
                            bottom: 20,
                            right: 13,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {

                                if(product.stockProduct == 0) return;

                                if(product.cantidadAgregada >= 0 && product.stockProduct != 0) {
                                  product.stockProduct --;
                                  product.cantidadAgregada ++;
                                }

                                productCartProvider.updateCart();
                                
                              },
                              child: Tooltip(
                                message: 'Añadir productos',
                                child: Icon(Icons.arrow_drop_up, size: 30)))
                            ),
                          Positioned(
                            bottom: 0,
                            right: 13,
                            child: GestureDetector(
                              onTap: () {

                                if(product.cantidadAgregada == 0) return;

                                if(product.cantidadAgregada > 0 && product.stockProduct >= 0) {
                                  product.stockProduct ++;
                                  product.cantidadAgregada --;
                                }

                                if(product.cantidadAgregada == 0) productCartProvider.deleteCart(product);

                                productCartProvider.updateCart();

                              },
                              child: Tooltip(
                                message: 'Eliminar productos',
                                child: Icon(Icons.arrow_drop_down, size: 30)),
                            )
                          ),
                        ],
                      ),
                    );
                  },
                ) 
              ),
            ],
          ),
        ),
        floatingActionButton: productCartProvider.listCart.isEmpty 
        ? FloatingActionButton(onPressed: null) 
        : FloatingActionButton(
          tooltip: 'Finalizar comprar',
          onPressed: (){
            productCartProvider.openCheckOut(context);

          },
          child: Icon(Icons.shopping_bag)
        )
      )
    );
  }
}
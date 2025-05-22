import 'package:flutter/material.dart';
import 'package:gestor_inventario/config/helpers/human_formats.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:provider/provider.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    final productProvider = context.watch<ProductsUserProvider>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title:  Text('Inicio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: productProvider.listProduct.isEmpty ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text('No hay productos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                              ),
                    ],
                  ):GridView.builder(

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
                                
                                tooltip: product.stockProduct == 0 ? 'No hay productos' : 'Añadir al carrito',
                                
                                onPressed: product.stockProduct == 0 ? null : (){
                          
                                  if(product.stockProduct <= 0){
                                    return;
                                  } 
                                  product.stockProduct --;
                                  product.cantidadAgregada ++;
                                  if(productProvider.listCart.any((p) => p.nameProduct == product.nameProduct)) return productProvider.updateCart();

                                  productProvider.addCart(product);

                                },
                                icon: Icon(Icons.shopping_cart)),
                              SizedBox(width: 5)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [ 
                                Text('\$${HumanFormats.humanReadbleNumber( product.priceProduct )}'),
                                Text('Stock: ${ HumanFormats.humanReadbleNumber( product.stockProduct )}')
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
          ),
        ),
      )
    );
  }
}
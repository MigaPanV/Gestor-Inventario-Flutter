import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/products_client_provider.dart';
import 'package:provider/provider.dart';

class ClientHome extends StatelessWidget {
  const ClientHome({super.key});

  @override
  Widget build(BuildContext context) {

    final productProvider = context.watch<ProductsClientProvider>();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Inicio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
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
                      
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.imageurl,
                                fit: BoxFit.cover,
                                width: double.infinity,
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

                                IconButton(onPressed: (){

                                  productProvider.addCart(product);
                                }, icon: Icon(Icons.shopping_cart)),

                                SizedBox(width: 5,)
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('\$${product.priceProduct}'),
                            ),

                            SizedBox(height: 5),
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
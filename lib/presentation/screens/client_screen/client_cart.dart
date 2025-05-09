import 'package:flutter/material.dart';
import 'package:gestor_inventario/presentation/providers/products_client_provider.dart';
import 'package:provider/provider.dart';

class ClientCart extends StatelessWidget {
  const ClientCart({super.key});

  @override
  Widget build(BuildContext context) {
    final productCartProvider = context.watch<ProductsClientProvider>();

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  
                  itemCount: productCartProvider.listCart.length,
                  itemBuilder: (context, index){
                    final productCart = productCartProvider.listCart[index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: Image.network(productCart.imageurl),
                          title: Text(productCart.nameProduct),
                          subtitle: Text('Precio: \$${productCart.priceProduct}'),
                          
                        ),
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
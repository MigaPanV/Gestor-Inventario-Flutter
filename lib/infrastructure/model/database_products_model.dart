import 'package:gestor_inventario/domain/entities/product.dart';

class DatabaseProductsModel {

  final String nameProduct;
  final String descriptionProduct;
  final int priceProduct;
  int stockProduct;
  final String imageurl;
  final String sku;

  DatabaseProductsModel({
    required this.nameProduct, 
    required this.descriptionProduct, 
    required this.priceProduct, 
    required this.stockProduct, 
    required this.imageurl,
    required this.sku, 

    });

  factory DatabaseProductsModel.fromFirestore(Map<String, dynamic> firestore)  => DatabaseProductsModel(
    nameProduct: firestore['name'] ?? 'No name',
    descriptionProduct: firestore['description'] ?? 'No description',
    imageurl: firestore['imageurl'] ?? 'No image url',
    priceProduct: firestore['price'] ?? 0,
    stockProduct: firestore['stock'] ?? 0,
    sku: firestore['sku'] ?? 'No sku'
  );

  Map<String, dynamic> tofirebase() => {
    'name': nameProduct,
    'description': descriptionProduct,
    'imageurl': imageurl,
    'price': priceProduct,
    'stock': stockProduct,
    'sku': sku
  };

  Product toProductEntity() => Product(
    nameProduct: nameProduct,
    descriptionProduct: descriptionProduct,
    priceProduct: priceProduct,
    stockProduct: stockProduct,
    imageurl: imageurl,
    sku: sku
  );

}
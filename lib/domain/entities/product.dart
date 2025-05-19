class Product {

  final String nameProduct;
  final String descriptionProduct;
  final int priceProduct;
  int stockProduct;
  int cantidadAgregada;
  final String imageurl;
  final String sku;

  Product({
    required this.nameProduct, 
    required this.descriptionProduct, 
    required this.priceProduct, 
    required this.stockProduct, 
    required this.imageurl,
    required this.sku, 
    this.cantidadAgregada = 0
    
    });
}
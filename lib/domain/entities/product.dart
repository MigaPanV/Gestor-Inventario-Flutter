class Product {

  final String nameProduct;
  final String descriptionProduct;
  final int priceProduct;
  int stockProduct;
  int cantidadAgregada;
  final String imageurl;

  Product({
    required this.nameProduct, 
    required this.descriptionProduct, 
    required this.priceProduct, 
    required this.stockProduct, 
    required this.imageurl,
    this.cantidadAgregada = 0
    
    });
}
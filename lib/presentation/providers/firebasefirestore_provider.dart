
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/infrastructure/model/database_products_model.dart';

class FirebasefirestoreProvider extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  bool isUploaded = false;

  String nameProduct = '';
  String descriptionProduct = '';
  String imageurl = '' ;
  int stockProduct = 0;
  int priceProduct = 0;

  String? errorgeneral;

  void clearData(){

    nameProduct = '';
    descriptionProduct = '';
    imageurl = '' ;
    stockProduct = 0;
    priceProduct = 0;
    notifyListeners();

  }

  bool validateTextField(){
    if (nameProduct.isEmpty || descriptionProduct.isEmpty || imageurl.isEmpty) {
      errorgeneral = 'Los campos no pueden estar vacíos';
      notifyListeners();
      return false;
    }
    errorgeneral = null;
    return true;
  }
  
  void getName(String value){
    nameProduct = value;
    notifyListeners();
  }

  void getDescription(String value){
    descriptionProduct = value;
    notifyListeners();
  }

  void getPrice(String value){
    priceProduct = int.parse(value);
    notifyListeners();
  }
  
  void getStock(String value){
    stockProduct = int.parse(value);
    notifyListeners();
  }

  void getUrl(String value){
    imageurl = value;
    notifyListeners();
  }
  
  void setLoading(bool value) {
  isLoading = value;
  notifyListeners();
}

void setUploaded(bool value) {
  isUploaded = value;
  notifyListeners();
}

  Future<void> addProduct() async{
    isUploaded = false;
    isLoading = false;

    final product = DatabaseProductsModel(
      nameProduct: nameProduct, 
      descriptionProduct: descriptionProduct, 
      imageurl: imageurl,
      stockProduct: stockProduct,
      priceProduct: priceProduct
      );
    
    try{

      isLoading = true;
      await firestore.collection('productos').add( product.tofirebase() );
      debugPrint('producto añadido');
      isLoading = false;
      isUploaded = true;

    }on FirebaseException catch (e){
      debugPrint(e.code);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<List<Product>> getProducts() async{

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('productos').get();
    
    return querySnapshot.docs.map((doc) => DatabaseProductsModel.fromFirestore(doc.data() as Map<String, dynamic>).toProductEntity()).toList();
  }


}
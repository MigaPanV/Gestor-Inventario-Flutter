
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/infrastructure/model/database_products_model.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:gestor_inventario/services/select_images.dart';
import 'package:provider/provider.dart';

class FirebasefirestoreProvider extends ChangeNotifier{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  bool isLoading = false;
  bool isUploaded = false;

  String nameProduct = '';
  String descriptionProduct = '';
  String imageurl = '' ;
  int stockProduct = 0;
  int priceProduct = 0;
  String sku = '';

  String newNameProduct = '';
  String newDescriptionProduct = '';
  int newStockProduct = 0;
  int newPriceProduct = 0;

  File? imageToUpload;

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
    if (nameProduct.isEmpty || descriptionProduct.isEmpty ) {
      errorgeneral = 'Los campos no pueden estar vacíos';
      notifyListeners();
      return false;
    }
    errorgeneral = null;
    return true;
  }

  void getNewName(String value){
    newNameProduct = value;
    notifyListeners();
  }
  void getNewDescription(String value){
    newDescriptionProduct = value;
    notifyListeners();
  }
  void getNewStock(String value){
    newStockProduct = int.parse(value);
    notifyListeners();
  }
  void getnewprice(String value){
    newPriceProduct = int.parse(value);
    notifyListeners();
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

  void generateSKU(String productName) {
  final prefix = productName.length >= 3
      ? productName.substring(0, 3).toUpperCase()
      : productName.toUpperCase();
  
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7); 
  sku = '$prefix-$timestamp';
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
      priceProduct: priceProduct,
      sku: sku
      );
    
    try{

      isLoading = true;
      await firestore.collection('productos').doc(sku).set(product.tofirebase());
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

  Future<void> getImage() async{

    final image = await getImages();
    imageToUpload = File(image!.path);
    notifyListeners();
  }

  Future<bool> uploadImage() async{

    final String nameFile = imageToUpload!.path.split('/').last;

    final Reference ref = storage.ref().child('images').child(nameFile);
    
    final UploadTask uploadTask = ref.putFile(imageToUpload!);

    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);

    final String url = await snapshot.ref.getDownloadURL();

    getUrl(url);
    notifyListeners();

    if(snapshot.state == TaskState.success){
      return true;
    }
    return false;
  }

  Future<void> deleteProduct(BuildContext context, Product product) async{

    final clientProvider = context.read<ProductsClientProvider>();

    try{
      isLoading = true;
      clientProvider.deleteToList(product);
      await firestore.collection("productos").doc(product.sku).delete();
      isLoading = false;
      isUploaded = true;
    }on FirebaseException catch (e){

      debugPrint(e.code);

    }
    isLoading = false;
    
    notifyListeners();
  }

  Future<void> setProduct(BuildContext context, Product product) async{
    isUploaded = false;
    isLoading = false;
    final clientProvider = context.read<ProductsClientProvider>();

    final newProduct = DatabaseProductsModel(
      nameProduct: newNameProduct, 
      descriptionProduct: newDescriptionProduct, 
      imageurl: imageurl,
      stockProduct: newStockProduct,
      priceProduct: newPriceProduct,
      sku: product.sku
      );
    
    try{

      isLoading = true;
      await firestore.collection('productos').doc(product.sku).set(newProduct.tofirebase());
      clientProvider.updateList();
      debugPrint('producto actualizado');
      isLoading = false;
      isUploaded = true;

    }on FirebaseException catch (e){
      debugPrint(e.code);
    }
    isLoading = false;
    notifyListeners();
  }


}
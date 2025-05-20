import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/infrastructure/model/database_products_model.dart';
import 'package:gestor_inventario/presentation/providers/products_user_provider.dart';
import 'package:gestor_inventario/services/select_images.dart';
import 'package:provider/provider.dart';

class FirebasefirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  bool isLoading = false;
  bool isUploaded = false;

  String nameProduct = '';
  String descriptionProduct = '';

  String imageurl = '';
  String sku = '';

  String newNameProduct = '';
  String newDescriptionProduct = '';
  int newStockProduct = 0;
  int newPriceProduct = 0;

  String priceInput = '';
  String stockInput = '';

  int? stockProduct;
  int? priceProduct;
  File? imageToUpload;

  String? errorName;
  String? errorDescription;
  String? errorPrice;
  String? errorStock;
  String? errorImage;

  void clearData() {
    nameProduct = '';
    descriptionProduct = '';
    imageurl = '';
    imageToUpload = null;
    priceInput = '';
    stockInput = '';
    stockProduct = null;
    priceProduct = null;
    errorName = null;
    errorDescription = null;
    errorPrice = null;
    errorStock = null;
    errorImage = null;
    sku = '';
    notifyListeners();
  }

  bool validateTextField() {
  bool isValid = true;

  if (nameProduct.isEmpty) {
    errorName = 'El nombre es obligatorio';
    isValid = false;
  } else {
    errorName = null;
  }

  if (descriptionProduct.isEmpty) {
    errorDescription = 'La descripción es obligatoria';
    isValid = false;
  } else {
    errorDescription = null;
  }

  if (priceInput.isEmpty) {
    errorPrice = 'El precio es obligatorio';
    isValid = false;
  } else if (int.tryParse(priceInput) == null) {
    errorPrice = 'No es un valor numérico';
    isValid = false;
  } else {
    errorPrice = null;
    priceProduct = int.parse(priceInput);
  }

  if (stockInput.isEmpty) {
    errorStock = 'El stock es obligatorio';
    isValid = false;
  } else if (int.tryParse(stockInput) == null) {
    errorStock = 'No es un valor numérico';
    isValid = false;
  } else {
    errorStock = null;
    stockProduct = int.parse(stockInput);
  }

  if (imageToUpload == null) {
    errorImage = 'Debe seleccionar una imagen';
    isValid = false;
  } else {
    errorImage = null;
  }

  notifyListeners();
  return isValid;
}

  bool validateEditFields() {
    bool isValid = true;

    if (newNameProduct.isEmpty) {
      errorName = 'El nombre es obligatorio';
      isValid = false;
    } else {
      errorName = null;
    }

    if (newDescriptionProduct.isEmpty) {
      errorDescription = 'La descripción es obligatoria';
      isValid = false;
    } else {
      errorDescription = null;
    }

    if (newPriceProduct <= 0) {
      errorPrice = 'El precio debe ser un número positivo';
      isValid = false;
    } else {
      errorPrice = null;
    }

    if (newStockProduct < 0) {
      errorStock = 'El stock no puede ser negativo';
      isValid = false;
    } else {
      errorStock = null;
    }

    notifyListeners();
    return isValid;
  }

  bool validateUpdateFields({
    required String? name,
    required String? description,
    required String? price,
    required String? stock,
}) {
  bool isValid = true;

  if (name == null || name.trim().isEmpty) {
    errorName = 'Nombre no puede estar vacío';
    isValid = false;
  } else {
    errorName = null;
  }
  if (description == null || description.trim().isEmpty) {
    errorDescription = 'Descripcion no puede estar vacío';
    isValid = false;
  } else {
    errorDescription = null;
  }

  if (price == null || price.trim().isEmpty) {
  errorPrice = 'El campo de precio no puede estar vacío';
  isValid = false;
} else {
  final priceValue = int.tryParse(price.trim());
  if (priceValue == null) {
    errorPrice = 'Debe ser un número válido';
    isValid = false;
  } else if (priceValue < 0) {
    errorPrice = 'Debe ser un número positivo';
    isValid = false;
  } else {
    errorPrice = null;
  }
}

  if (stock == null || stock.trim().isEmpty) {
  errorStock = 'El campo stock no puede estar vacío';
  isValid = false;
} else {
  final stockValue = int.tryParse(stock.trim());
  if (stockValue == null) {
    errorStock = 'Debe ser un número válido';
    isValid = false;
  } else if (stockValue < 0) {
    errorStock = 'Debe ser un número positivo';
    isValid = false;
  } else {
    errorStock = null;
  }
}

  notifyListeners();
  return isValid;
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
  final parsedValue = int.tryParse(value);
  if (parsedValue != null) {
    newStockProduct = parsedValue;
  } else {
    errorStock = 'El valor del stock no es numérico';
  }
  notifyListeners();
}

void getnewprice(String value){
  final parsedValue = int.tryParse(value);
  if (parsedValue != null) {
    newPriceProduct = parsedValue;
  } else {
    errorPrice = 'El valor del precio no es numérico';
  }
  notifyListeners();
}
  
  void loadProductToEdit(Product product) {
  newNameProduct = product.nameProduct;
  newDescriptionProduct = product.descriptionProduct;
  newPriceProduct = product.priceProduct;
  newStockProduct = product.stockProduct;
  imageurl = product.imageurl;
  notifyListeners();
}

  void getName(String value){
    nameProduct = value;
    errorName = null;
    notifyListeners();
  }

  void getDescription(String value) {
    descriptionProduct = value;
    errorDescription = null;
    notifyListeners();
  }

  void getPrice(String value) {
    priceInput = value;
    priceProduct = int.tryParse(value);
    errorPrice = null;
    notifyListeners();
  }

  void getStock(String value) {
    stockInput = value;
    stockProduct = int.tryParse(value);
    errorStock = null;
    notifyListeners();
  }

  void getUrl(String value) {
    imageurl = value;
    errorImage = null;
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

  Future<void> addProduct() async {
    isUploaded = false;
    isLoading = false;

    if (!validateTextField()) return;

    final product = DatabaseProductsModel(
      nameProduct: nameProduct,
      descriptionProduct: descriptionProduct,
      imageurl: imageurl,
      stockProduct: stockProduct!,
      priceProduct: priceProduct!,
      sku: sku
    );
    try {
      isLoading = true;
      notifyListeners();
      
      await firestore.collection('productos').doc(sku).set(product.tofirebase());
      isUploaded = true;
    } 
    on FirebaseException catch (e) {
      debugPrint(e.code);
    } 
    finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> getProducts() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('productos').get();
    return querySnapshot.docs
        .map((doc) => DatabaseProductsModel.fromFirestore(doc.data() as Map<String, dynamic>).toProductEntity())
        .toList();
  }

  Future<void> getImage() async {
    final image = await getImages();
    if (image != null) {
      imageToUpload = File(image.path);
      notifyListeners();
    }
  }

  Future<bool> uploadImage() async {
    if (imageToUpload == null) return false;

    final String nameFile = imageToUpload!.path.split('/').last;
    final Reference ref = storage.ref().child('images').child(nameFile);
    final UploadTask uploadTask = ref.putFile(imageToUpload!);

    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);
    
    final String url = await snapshot.ref.getDownloadURL();

    getUrl(url);

    return snapshot.state == TaskState.success;
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

    if (!validateEditFields()) return;

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

  Future<void> updateStockAfterPurchase(String sku, int cantidad) async{
    final docRef = firestore.collection('productos').doc(sku);

    try{

      final docSnapshot = await docRef.get();

      if(docSnapshot.exists){
        int stockActual = docSnapshot.get('stock');
        int nuevoStock = stockActual - cantidad;
        if(nuevoStock < 0) nuevoStock = 0;
        await docRef.update({'stock' : nuevoStock});
      }

    }on FirebaseException catch(e){
      debugPrint(e.code);
    }
  }
}
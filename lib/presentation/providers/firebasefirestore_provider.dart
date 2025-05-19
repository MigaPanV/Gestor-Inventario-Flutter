import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gestor_inventario/domain/entities/product.dart';
import 'package:gestor_inventario/infrastructure/model/database_products_model.dart';
import 'package:gestor_inventario/services/select_images.dart';

class FirebasefirestoreProvider extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  bool isLoading = false;
  bool isUploaded = false;

  String nameProduct = '';
  String descriptionProduct = '';
  String imageurl = '';

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
    priceInput = '';
    stockInput = '';
    stockProduct = null;
    priceProduct = null;
    errorName = null;
    errorDescription = null;
    errorPrice = null;
    errorStock = null;
    errorImage = null;
    notifyListeners();
  }

  bool validateTextField() {
    bool isValid = true;

    if (nameProduct.isEmpty) {
      errorName = 'El nombre es obligatorio';
      isValid = false;
    } 
    else {
      errorName = null;
    }

    if (descriptionProduct.isEmpty) {
      errorDescription = 'La descripción es obligatoria';
      isValid = false;
    } 
    else {
      errorDescription = null;
    }

    if (priceInput.isEmpty) {
      errorPrice = 'El precio es obligatorio';
      isValid = false;
    } 
    else if (int.tryParse(priceInput) == null) {
      errorPrice = 'No es un valor numérico';
      isValid = false;
    } 
    else {
      errorPrice = null;
      priceProduct = int.parse(priceInput);
    }

    if (stockInput.isEmpty) {
      errorStock = 'El stock es obligatorio';
      isValid = false;
    } 
    else if (int.tryParse(stockInput) == null) {
      errorStock = 'No es un valor numérico';
      isValid = false;
    } 
    else {
      errorStock = null;
      stockProduct = int.parse(stockInput);
    }

    notifyListeners();
    return isValid;
  }

  void getName(String value) {
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
    );

    try {
      isLoading = true;
      notifyListeners();
      await firestore.collection('productos').doc(nameProduct).set(product.tofirebase());
      debugPrint('producto añadido');
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
}

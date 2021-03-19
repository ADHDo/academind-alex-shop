import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

import '../models/http_exception.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products {
    return [..._products];
  }

  List<Product> get favoriteProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _products.indexWhere((element) => element.id == id);
    final url = Uri.https(
      'flutter-update-5d433-default-rtdb.firebaseio.com',
      '/products/$id.json',
    );
    try {
      http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _products[prodIndex] = newProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
      'flutter-update-5d433-default-rtdb.firebaseio.com',
      '/products.json',
    );
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) return;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite: prodData['isFavorite'],
            imageUrl: prodData['imageUrl'],
          ),
        );
      });
      _products = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'flutter-update-5d433-default-rtdb.firebaseio.com',
      '/products.json',
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
      'flutter-update-5d433-default-rtdb.firebaseio.com',
      '/products/$id.json',
    );
    final existingProductIndex = _products.indexWhere((p) => p.id == id);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}

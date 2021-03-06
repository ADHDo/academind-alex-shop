import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  _resetFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  toggleFavoriteStatus() async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.https(
      'flutter-update-5d433-default-rtdb.firebaseio.com',
      '/products/$id.json',
    );
    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavorite': isFavorite,
        }),
      );
      if (response.statusCode >= 400) {
        _resetFavValue(oldStatus);
      }
    } catch (error) {
      _resetFavValue(oldStatus);
    }
  }
}

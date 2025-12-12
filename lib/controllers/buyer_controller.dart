import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/order_service.dart';

class BuyerController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Map<String, dynamic>> _crops = [];
  List<Map<String, dynamic>> _seeds = [];
  List<Map<String, dynamic>> _machinery = [];
  List<Map<String, dynamic>> _favorites = <Map<String, dynamic>>[];
  bool _isLoading = false;
  String? _errorMessage;
  
  static const String _favoritesKey = 'user_favorites';

  List<Map<String, dynamic>> get crops => _crops;
  List<Map<String, dynamic>> get seeds => _seeds;
  List<Map<String, dynamic>> get machinery => _machinery;
  List<Map<String, dynamic>> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<QuerySnapshot> getCropsStream() {
    return _firestore.collection('crops').snapshots();
  }

  Stream<QuerySnapshot> getSeedsStream() {
    return _firestore.collection('seeds').snapshots();
  }

  Stream<QuerySnapshot> getMachineryStream() {
    OrderService.updateExpiredRentals();
    return OrderService.getAvailableMachinery();
  }

  Future<void> loadCrops() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('crops').get();
      _crops = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSeeds() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('seeds').get();
      _seeds = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> placeOrder(Map<String, dynamic> orderData) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('orders').add(orderData);

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void addToFavorites(Map<String, dynamic> product) {
    final existingIndex = _favorites.indexWhere((fav) => 
      (fav['id'] ?? fav['name']) == (product['id'] ?? product['name']));
    
    if (existingIndex != -1) {
      _favorites.removeAt(existingIndex);
    } else {
      _favorites.add(Map<String, dynamic>.from(product));
    }
    notifyListeners(); // Notify UI first for instant update
    _saveFavorites(); // Save in background
  }

  bool isFavorite(Map<String, dynamic> product) {
    return _favorites.any((fav) => 
      (fav['id'] ?? fav['name']) == (product['id'] ?? product['name']));
  }

  List<Map<String, dynamic>> getFavoriteProducts() {
    return _favorites;
  }
  
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
    _saveFavorites();
  }
  
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        _favorites = favoritesList.map((item) {
          final Map<String, dynamic> product = Map<String, dynamic>.from(item);
          // Convert milliseconds back to Timestamp if needed
          product.forEach((key, value) {
            if (key.contains('date') || key.contains('time')) {
              if (value is int) {
                product[key] = Timestamp.fromMillisecondsSinceEpoch(value);
              }
            }
          });
          return product;
        }).toList();
        print('Loaded ${_favorites.length} favorites from storage');
        notifyListeners();
      } else {
        print('No favorites found in storage');
      }
    } catch (e) {
      print('Error loading favorites: $e');
      _favorites = [];
    }
  }
  
  void _saveFavorites() {
    // Save asynchronously without blocking UI
    Future.microtask(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        // Convert Firestore objects to JSON-safe format
        final jsonSafeFavorites = _favorites.map((product) {
          final Map<String, dynamic> jsonSafe = {};
          product.forEach((key, value) {
            if (value is Timestamp) {
              jsonSafe[key] = value.millisecondsSinceEpoch;
            } else {
              jsonSafe[key] = value;
            }
          });
          return jsonSafe;
        }).toList();
        
        final favoritesJson = jsonEncode(jsonSafeFavorites);
        await prefs.setString(_favoritesKey, favoritesJson);
        print('Saved ${_favorites.length} favorites to storage');
      } catch (e) {
        print('Error saving favorites: $e');
      }
    });
  }
}

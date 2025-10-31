import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ProductController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<DocumentSnapshot> _crops = [];
  List<DocumentSnapshot> _seeds = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DocumentSnapshot> get crops => _crops;
  List<DocumentSnapshot> get seeds => _seeds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final cropsQuery = await _firestore
          .collection('crops')
          .where('userId', isEqualTo: userId)
          .get();
      
      final seedsQuery = await _firestore
          .collection('seeds')
          .where('userId', isEqualTo: userId)
          .get();

      _crops = cropsQuery.docs;
      _seeds = seedsQuery.docs;
      _setLoading(false);
    } catch (e) {
      _setError('Error loading products: ${e.toString()}');
      _setLoading(false);
    }
  }

  Stream<QuerySnapshot> getCropsStream() async* {
    final userId = await AuthService.getUserId();
    if (userId == null) return;
    
    yield* _firestore
        .collection('crops')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> getSeedsStream() async* {
    final userId = await AuthService.getUserId();
    if (userId == null) return;
    
    yield* _firestore
        .collection('seeds')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<bool> addProduct(Map<String, dynamic> productData, String collection) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      productData['userId'] = userId;
      productData['timestamp'] = FieldValue.serverTimestamp();

      await _firestore.collection(collection).add(productData);
      await loadProducts();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error adding product: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProduct(String docId, Map<String, dynamic> productData, String collection) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _firestore.collection(collection).doc(docId).update(productData);
      await loadProducts();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating product: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProduct(String docId, String collection) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _firestore.collection(collection).doc(docId).delete();
      await loadProducts();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error deleting product: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  int getCropsCount() => _crops.length;
  int getSeedsCount() => _seeds.length;
}
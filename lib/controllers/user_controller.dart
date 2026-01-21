import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class UserController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  Future<void> loadUserData() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userData = doc.data();
      }
      _setLoading(false);
    } catch (e) {
      _setError('Error loading user data: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not logged in');

      await _firestore.collection('users').doc(uid).update(data);
      await loadUserData();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating user data: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  String get userName => _userData?['name'] ?? '';
  String get userEmail => _userData?['email'] ?? '';
  String get userPhone => _userData?['phone'] ?? '';
  String get userAddress => _userData?['address'] ?? '';
  String get userRole => _userData?['role'] ?? '';
}
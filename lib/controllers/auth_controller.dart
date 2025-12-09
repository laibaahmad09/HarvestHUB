import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password, String role) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user?.uid;
      if (uid == null) throw Exception('User ID not found');

      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || !doc.data()!.containsKey('role')) {
        throw Exception('User data or role missing in database');
      }

      final fetchedRole = doc.data()!['role'] as String;
      if (fetchedRole != role) {
        throw Exception('User with this role not found');
      }

      await AuthService.saveLoginState(uid, fetchedRole);
      _currentUser = credential.user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError('Login failed: ${e.message}');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup(String name, String phone, String address, String email, String password, String role, String profileImageBase64) async {
    try {
      _setLoading(true);
      _setError(null);

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email.trim(),
        'name': name.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'role': role,
        'profileImageBase64': profileImageBase64,
      });

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError('Signup failed: ${e.code}');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Signup failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await AuthService.clearLoginState();
    _currentUser = null;
    notifyListeners();
  }
}
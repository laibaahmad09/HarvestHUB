import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class MachineryController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<DocumentSnapshot> _machinery = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';

  List<DocumentSnapshot> get machinery => _machinery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    loadMachinery();
  }

  Future<void> loadMachinery() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      Query query = _firestore
          .collection('machinery')
          .where('userId', isEqualTo: userId);

      if (_selectedCategory != 'All') {
        query = query.where('category', isEqualTo: _selectedCategory);
      }

      final querySnapshot = await query.get();
      _machinery = querySnapshot.docs;
      _setLoading(false);
    } catch (e) {
      _setError('Error loading machinery: ${e.toString()}');
      _setLoading(false);
    }
  }

  Stream<QuerySnapshot> getMachineryStream() async* {
    final userId = await AuthService.getUserId();
    if (userId == null) return;
    
    Query query = _firestore
        .collection('machinery')
        .where('userId', isEqualTo: userId);

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    yield* query.snapshots();
  }

  Future<bool> addMachinery(Map<String, dynamic> machineryData) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      machineryData['userId'] = userId;
      machineryData['timestamp'] = FieldValue.serverTimestamp();

      await _firestore.collection('machinery').add(machineryData);
      await loadMachinery();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error adding machinery: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateMachinery(String docId, Map<String, dynamic> machineryData) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _firestore.collection('machinery').doc(docId).update(machineryData);
      await loadMachinery();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error updating machinery: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteMachinery(String docId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _firestore.collection('machinery').doc(docId).delete();
      await loadMachinery();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error deleting machinery: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  int getTotalCount() => _machinery.length;
  
  int getAvailableCount() {
    return _machinery.where((m) {
      final data = m.data() as Map<String, dynamic>;
      final availability = data['availability']?.toString().toLowerCase() ?? 'available';
      return availability == 'available' && (data['isAvailable'] == true);
    }).length;
  }
  
  int getRentedCount() {
    return _machinery.where((m) {
      final data = m.data() as Map<String, dynamic>;
      final availability = data['availability']?.toString().toLowerCase() ?? 'available';
      return availability == 'rented';
    }).length;
  }
}
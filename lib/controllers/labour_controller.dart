import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class LabourController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, dynamic>? _labourProfile;
  List<DocumentSnapshot> _hireRequests = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAvailable = true;

  Map<String, dynamic>? get labourProfile => _labourProfile;
  List<DocumentSnapshot> get hireRequests => _hireRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAvailable => _isAvailable;

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

  // Register/Update labour profile
  Future<bool> registerLabourProfile({
    required String name,
    required String phone,
    required String address,
    required List<String> skills,
    required String experience,
    required double dailyRate,
    required double hourlyRate,
    required String availability,
    String? description,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      final profileData = {
        'userId': userId,
        'name': name,
        'phone': phone,
        'address': address,
        'skills': skills,
        'experience': experience,
        'dailyRate': dailyRate,
        'hourlyRate': hourlyRate,
        'availability': availability,
        'description': description ?? '',
        'isAvailable': true,
        'rating': 0.0,
        'totalJobs': 0,
        'totalEarning': 0,
        'todayEarning': 0,
        'registeredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('labour_profiles').doc(userId).set(profileData);
      await loadLabourProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error registering profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Load labour profile
  Future<void> loadLabourProfile() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      // Check for auto-completion first
      await checkAutoCompletion();

      final doc = await _firestore.collection('labour_profiles').doc(userId).get();
      if (doc.exists) {
        _labourProfile = doc.data();
        _isAvailable = _labourProfile?['isAvailable'] ?? true;
        
        // Load today's earning
        await _loadTodayEarning(userId);
      }
      _setLoading(false);
    } catch (e) {
      _setError('Error loading profile: ${e.toString()}');
      _setLoading(false);
    }
  }
  
  // Load today's earning
  Future<void> _loadTodayEarning(String userId) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final todayEarningDoc = await _firestore
          .collection('labour_daily_earnings')
          .doc('${userId}_${todayStart.millisecondsSinceEpoch}')
          .get();
          
      if (todayEarningDoc.exists) {
        final todayEarning = todayEarningDoc.data()?['amount'] ?? 0;
        _labourProfile?['todayEarning'] = todayEarning;
      } else {
        _labourProfile?['todayEarning'] = 0;
      }
    } catch (e) {
      _labourProfile?['todayEarning'] = 0;
    }
  }

  // Load hire requests for this labourer
  Future<void> loadHireRequests() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) return;

      final querySnapshot = await _firestore
          .collection('hire_requests')
          .where('labourId', isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      _hireRequests = querySnapshot.docs;
      _setLoading(false);
    } catch (e) {
      _setError('Error loading hire requests: ${e.toString()}');
      _setLoading(false);
    }
  }

  // Accept/Reject hire request
  Future<bool> respondToHireRequest(String requestId, String response) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _firestore.collection('hire_requests').doc(requestId).update({
        'status': response,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // If accepted, mark labourer as unavailable and set auto-completion
      if (response == 'accepted') {
        final userId = await AuthService.getUserId();
        if (userId != null) {
          // Get request data to calculate end time
          final requestDoc = await _firestore.collection('hire_requests').doc(requestId).get();
          final requestData = requestDoc.data();
          
          if (requestData != null) {
            final quantity = requestData['quantity']?.toDouble() ?? 1;
            final durationType = requestData['durationType'] ?? 'Days';
            
            // Calculate end time
            final now = DateTime.now();
            DateTime endTime;
            
            if (durationType == 'Days') {
              endTime = now.add(Duration(days: quantity.toInt()));
            } else { // Hours
              endTime = now.add(Duration(hours: quantity.toInt()));
            }
            
            await _firestore.collection('hire_requests').doc(requestId).update({
              'acceptedAt': FieldValue.serverTimestamp(),
              'autoCompleteAt': Timestamp.fromDate(endTime),
            });
          }
          
          await _firestore.collection('labour_profiles').doc(userId).update({
            'isAvailable': false,
            'currentJobId': requestId,
          });
          _isAvailable = false;
        }
      }

      await loadHireRequests();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error responding to request: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Complete job and become available again
  Future<bool> completeJob(String requestId) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      // Get the hire request to calculate payment
      final requestDoc = await _firestore.collection('hire_requests').doc(requestId).get();
      final requestData = requestDoc.data();
      
      double jobPayment = 0;
      if (requestData != null) {
        // Use the totalAmount that was calculated and saved during hire request
        jobPayment = requestData['totalAmount']?.toDouble() ?? 0;
      }

      // Update hire request status
      await _firestore.collection('hire_requests').doc(requestId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'payment': jobPayment,
      });

      // Get current date for today's earning
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Update labour profile with earnings and job count
      await _firestore.collection('labour_profiles').doc(userId).update({
        'isAvailable': true,
        'currentJobId': FieldValue.delete(),
        'totalJobs': FieldValue.increment(1),
        'totalEarning': FieldValue.increment(jobPayment),
      });
      
      // Update today's earning
      final todayEarningDoc = await _firestore
          .collection('labour_daily_earnings')
          .doc('${userId}_${todayStart.millisecondsSinceEpoch}')
          .get();
          
      if (todayEarningDoc.exists) {
        await _firestore
            .collection('labour_daily_earnings')
            .doc('${userId}_${todayStart.millisecondsSinceEpoch}')
            .update({
          'amount': FieldValue.increment(jobPayment),
        });
      } else {
        await _firestore
            .collection('labour_daily_earnings')
            .doc('${userId}_${todayStart.millisecondsSinceEpoch}')
            .set({
          'userId': userId,
          'date': todayStart,
          'amount': jobPayment,
        });
      }

      _isAvailable = true;
      await loadHireRequests();
      await loadLabourProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error completing job: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Get hire requests stream
  Stream<QuerySnapshot> getHireRequestsStream() async* {
    final userId = await AuthService.getUserId();
    if (userId == null) return;
    
    yield* _firestore
        .collection('hire_requests')
        .where('labourId', isEqualTo: userId)
        .snapshots();
  }

  // Get completed jobs stream for work history
  Stream<QuerySnapshot> getCompletedJobsStream() async* {
    final userId = await AuthService.getUserId();
    if (userId == null) return;
    
    yield* _firestore
        .collection('hire_requests')
        .where('labourId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  // Check if profile exists
  bool get hasProfile => _labourProfile != null;

  // Check and auto-complete expired jobs
  Future<void> checkAutoCompletion() async {
    try {
      final userId = await AuthService.getUserId();
      if (userId == null) return;
      
      final now = Timestamp.now();
      
      // Find accepted jobs that should be auto-completed
      final expiredJobs = await _firestore
          .collection('hire_requests')
          .where('labourId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .where('autoCompleteAt', isLessThanOrEqualTo: now)
          .get();
      
      // Auto-complete each expired job
      for (var doc in expiredJobs.docs) {
        await completeJob(doc.id);
      }
    } catch (e) {
      // Silent fail for background check
    }
  }

  // Delete profile and all related data
  Future<bool> deleteProfile() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User not logged in');

      // Delete labour profile
      await _firestore.collection('labour_profiles').doc(userId).delete();
      
      // Delete all hire requests for this labour
      final hireRequestsQuery = await _firestore
          .collection('hire_requests')
          .where('labourId', isEqualTo: userId)
          .get();
      
      for (var doc in hireRequestsQuery.docs) {
        await doc.reference.delete();
      }
      
      // Delete all daily earnings records
      final earningsQuery = await _firestore
          .collection('labour_daily_earnings')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (var doc in earningsQuery.docs) {
        await doc.reference.delete();
      }
      
      // Clear local data
      _labourProfile = null;
      _hireRequests = [];
      _isAvailable = true;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error deleting profile: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
}
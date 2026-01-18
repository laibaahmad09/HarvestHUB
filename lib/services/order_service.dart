import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create order for crops/seeds
  static Future<String?> createOrder({
    required Map<String, dynamic> itemData,
    required int quantity,
    required String orderType, // 'crops' or 'seeds'
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final itemId = itemData['id'];
      final currentStock = int.tryParse(itemData['stock']?.toString() ?? '0') ?? 0;
      
      // Check if enough stock is available
      if (currentStock < quantity) {
        throw Exception('Insufficient stock. Only $currentStock KG available.');
      }

      final price = itemData['price'] ?? 0;
      final totalAmount = (price is num ? price.toInt() : int.tryParse(price.toString()) ?? 0) * quantity;

      // Create order data
      final orderData = {
        'buyerId': user.uid,
        'sellerId': itemData['sellerId'] ?? itemData['userId'] ?? 'unknown',
        'itemId': itemId,
        'itemName': itemData['name'] ?? 'Unknown Item',
        'itemType': orderType,
        'quantity': quantity,
        'pricePerUnit': price,
        'totalAmount': totalAmount,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'itemData': itemData,
      };
      
      print('Creating order with data: $orderData');
      
      // Add order to orders collection (stock will be reduced when seller accepts)
      final docRef = await _firestore.collection('orders').add(orderData);
      print('Order created successfully with ID: ${docRef.id}');
      
      // Don't reduce stock here - it will be reduced when seller accepts the order
      
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Create rental request for machinery
  static Future<String?> createRentalRequest({
    required Map<String, dynamic> machineryData,
    required int days,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final machineryId = machineryData['id'];
      
      // Check if machinery is currently available
      final machineryDoc = await _firestore.collection('machinery').doc(machineryId).get();
      if (!machineryDoc.exists) {
        throw Exception('Machinery not found.');
      }
      
      final currentMachineryData = machineryDoc.data() as Map<String, dynamic>;
      final currentAvailability = currentMachineryData['availability']?.toString().toLowerCase() ?? 'available';
      
      if (currentAvailability == 'rented') {
        throw Exception('This machinery is currently rented and not available.');
      }
      
      // Check if machinery is available for the requested period
      if (startDate != null && endDate != null) {
        final isAvailable = await _checkMachineryAvailability(machineryId, startDate, endDate);
        if (!isAvailable) {
          throw Exception('Machinery is not available for the selected dates.');
        }
      }

      final pricePerDay = machineryData['pricePerDay'] ?? 0;
      final totalAmount = (pricePerDay is num ? pricePerDay.toInt() : int.tryParse(pricePerDay.toString()) ?? 0) * days;

      print('Creating rental: startDate=$startDate, endDate=$endDate, days=$days');
      
      // Ensure dates are not null
      if (startDate == null || endDate == null) {
        throw Exception('Start date and end date are required for machinery rental.');
      }
      
      // Create rental data
      final rentalData = {
        'buyerId': user.uid,
        'sellerId': machineryData['userId'] ?? 'unknown',
        'machineryId': machineryId,
        'machineryName': machineryData['name'],
        'days': days,
        'pricePerDay': pricePerDay,
        'totalAmount': totalAmount,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'status': 'pending',
        'requestDate': FieldValue.serverTimestamp(),
        'machineryData': machineryData,
      };
      
      // Add rental to rentals collection
      final docRef = await _firestore.collection('rentals').add(rentalData);
      print('Rental created with ID: ${docRef.id}');
      
      // Don't update machinery availability here - it will be updated when seller accepts the rental
      
      return docRef.id;
    } catch (e) {
      print('Error creating rental request: $e');
      return null;
    }
  }
  
  // Check if machinery is available for the requested period
  static Future<bool> _checkMachineryAvailability(String machineryId, DateTime startDate, DateTime endDate) async {
    try {
      // Check if there are any overlapping rentals
      final overlappingRentals = await _firestore
          .collection('rentals')
          .where('machineryId', isEqualTo: machineryId)
          .where('status', whereIn: ['confirmed', 'active'])
          .get();
      
      for (final doc in overlappingRentals.docs) {
        final data = doc.data();
        final rentalStart = (data['startDate'] as Timestamp?)?.toDate();
        final rentalEnd = (data['endDate'] as Timestamp?)?.toDate();
        
        if (rentalStart != null && rentalEnd != null) {
          // Check for date overlap
          if (startDate.isBefore(rentalEnd) && endDate.isAfter(rentalStart)) {
            return false; // Overlapping rental found
          }
        }
      }
      
      return true; // No overlapping rentals
    } catch (e) {
      print('Error checking machinery availability: $e');
      return false;
    }
  }

  // Get buyer's orders
  static Stream<QuerySnapshot> getBuyerOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      print('No authenticated user found for orders');
      return const Stream.empty();
    }
    
    print('Getting orders for buyer: ${user.uid}');
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .snapshots();
  }

  // Get buyer's rental requests
  static Stream<QuerySnapshot> getBuyerRentals() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    
    return _firestore
        .collection('rentals')
        .where('buyerId', isEqualTo: user.uid)
        .snapshots();
  }

  // Get seller's orders
  static Stream<QuerySnapshot> getSellerOrders() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .snapshots();
  }

  // Get seller's rental requests
  static Stream<QuerySnapshot> getSellerRentals() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    
    return _firestore
        .collection('rentals')
        .where('sellerId', isEqualTo: user.uid)
        .snapshots();
  }

  // Update order status
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      // If accepting order, reduce stock
      if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'accepted') {
        return await _reduceStockAndUpdateStatus(orderId, status);
      }
      
      // For other status updates (rejected, cancelled, etc.)
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
  
  // Reduce stock when order is accepted
  static Future<bool> _reduceStockAndUpdateStatus(String orderId, String status) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        // Get order document
        final orderRef = _firestore.collection('orders').doc(orderId);
        final orderSnapshot = await transaction.get(orderRef);
        
        if (!orderSnapshot.exists) {
          throw Exception('Order not found');
        }
        
        final orderData = orderSnapshot.data() as Map<String, dynamic>;
        final itemType = orderData['itemType'];
        final itemId = orderData['itemId'];
        final quantity = orderData['quantity'] ?? 0;
        
        // Get item document
        final itemRef = _firestore.collection(itemType).doc(itemId);
        final itemSnapshot = await transaction.get(itemRef);
        
        if (itemSnapshot.exists) {
          final itemData = itemSnapshot.data() as Map<String, dynamic>;
          final currentStock = int.tryParse(itemData['stock']?.toString() ?? '0') ?? 0;
          
          // Check if enough stock is available
          if (currentStock < quantity) {
            throw Exception('Insufficient stock. Only $currentStock KG available.');
          }
          
          final newStock = currentStock - quantity;
          
          // Reduce stock
          if (newStock <= 0) {
            transaction.update(itemRef, {
              'stock': '0',
              'status': 'Out of Stock',
              'availability': 'unavailable'
            });
          } else {
            transaction.update(itemRef, {'stock': newStock.toString()});
          }
        }
        
        // Update order status
        transaction.update(orderRef, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return true;
      });
    } catch (e) {
      print('Error reducing stock and updating status: $e');
      return false;
    }
  }

  // Update rental status
  static Future<bool> updateRentalStatus(String rentalId, String status) async {
    try {
      // If accepting rental, update machinery availability
      if (status.toLowerCase() == 'confirmed' || status.toLowerCase() == 'accepted') {
        return await _updateMachineryAvailabilityAndStatus(rentalId, status);
      }
      
      // If completing or cancelling rental, restore machinery availability
      if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'cancelled') {
        return await _restoreMachineryAvailability(rentalId, status);
      }
      
      // For other status updates (rejected, etc.)
      await _firestore.collection('rentals').doc(rentalId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating rental status: $e');
      return false;
    }
  }
  
  // Update machinery availability when rental is accepted
  static Future<bool> _updateMachineryAvailabilityAndStatus(String rentalId, String status) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        // Get rental document
        final rentalRef = _firestore.collection('rentals').doc(rentalId);
        final rentalSnapshot = await transaction.get(rentalRef);
        
        if (!rentalSnapshot.exists) {
          throw Exception('Rental not found');
        }
        
        final rentalData = rentalSnapshot.data() as Map<String, dynamic>;
        final machineryId = rentalData['machineryId'];
        final endDate = rentalData['endDate'] as Timestamp?;
        
        // Get machinery document
        final machineryRef = _firestore.collection('machinery').doc(machineryId);
        final machinerySnapshot = await transaction.get(machineryRef);
        
        if (machinerySnapshot.exists) {
          // Update machinery availability to rented
          transaction.update(machineryRef, {
            'availability': 'rented',
            'rentedUntil': endDate,
            'currentRentalId': rentalId,
          });
        }
        
        // Update rental status
        transaction.update(rentalRef, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return true;
      });
    } catch (e) {
      print('Error updating machinery availability and status: $e');
      return false;
    }
  }
  
  // Restore machinery availability when rental ends
  static Future<bool> _restoreMachineryAvailability(String rentalId, String status) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        // Get rental document
        final rentalRef = _firestore.collection('rentals').doc(rentalId);
        final rentalSnapshot = await transaction.get(rentalRef);
        
        if (!rentalSnapshot.exists) {
          throw Exception('Rental not found');
        }
        
        final rentalData = rentalSnapshot.data() as Map<String, dynamic>;
        final machineryId = rentalData['machineryId'];
        
        // Get machinery document
        final machineryRef = _firestore.collection('machinery').doc(machineryId);
        final machinerySnapshot = await transaction.get(machineryRef);
        
        if (machinerySnapshot.exists) {
          // Restore machinery availability
          transaction.update(machineryRef, {
            'availability': 'available',
            'rentedUntil': FieldValue.delete(),
            'currentRentalId': FieldValue.delete(),
          });
        }
        
        // Update rental status
        transaction.update(rentalRef, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return true;
      });
    } catch (e) {
      print('Error restoring machinery availability: $e');
      return false;
    }
  }
  
  // Check and update expired rentals (call this periodically)
  static Future<void> updateExpiredRentals() async {
    try {
      final now = DateTime.now();
      // Also check for orphaned machinery (rented but no active rental)
      final rentedMachinery = await _firestore
          .collection('machinery')
          .where('availability', isEqualTo: 'rented')
          .get();
      
      for (final machineryDoc in rentedMachinery.docs) {
        final machineryData = machineryDoc.data();
        final rentalId = machineryData['currentRentalId'];
        
        if (rentalId != null) {
          // Check if rental still exists
          final rentalDoc = await _firestore.collection('rentals').doc(rentalId).get();
          if (!rentalDoc.exists) {
            // Rental deleted, restore machinery
            await _firestore.collection('machinery').doc(machineryDoc.id).update({
              'availability': 'available',
              'rentedUntil': FieldValue.delete(),
              'currentRentalId': FieldValue.delete(),
            });
            print('Restored orphaned machinery: ${machineryDoc.id}');
          }
        }
      }
      
      // Check expired rentals
      final expiredRentals = await _firestore
          .collection('rentals')
          .where('endDate', isLessThan: Timestamp.fromDate(now))
          .get();
      
      for (final doc in expiredRentals.docs) {
        final data = doc.data();
        final status = data['status'];
        if (status == 'confirmed' || status == 'active') {
          await updateRentalStatus(doc.id, 'completed');
        }
      }
    } catch (e) {
      print('Error updating expired rentals: $e');
    }
  }
  
  // Get available machinery (not currently rented)
  static Stream<QuerySnapshot> getAvailableMachinery() {
    return _firestore
        .collection('machinery')
        .snapshots();
  }
}
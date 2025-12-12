import 'package:flutter/material.dart';
import '../../../utils/app_utils.dart';
import '../../../services/order_service.dart';

enum OrderType { crops, seeds, machinery }

class OrderRentScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final OrderType orderType;

  const OrderRentScreen({
    super.key,
    required this.itemData,
    required this.orderType,
  });

  @override
  State<OrderRentScreen> createState() => _OrderRentScreenState();
}

class _OrderRentScreenState extends State<OrderRentScreen> {
  int quantity = 1;
  int days = 1;
  DateTime? startDate;
  DateTime? endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderType == OrderType.machinery) {
      startDate = DateTime.now();
      endDate = DateTime.now().add(Duration(days: days));
    }
  }

  void _updateEndDate() {
    if (startDate != null) {
      setState(() {
        endDate = startDate!.add(Duration(days: days));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMachinery = widget.orderType == OrderType.machinery;
    final priceValue = isMachinery 
        ? (widget.itemData['pricePerDay'] ?? 0)
        : (widget.itemData['price'] ?? 0);
    final price = priceValue is num ? priceValue.toInt() : int.tryParse(priceValue.toString()) ?? 0;
    final totalPrice = isMachinery ? (price * days) : (price * quantity);
    final stock = isMachinery ? 1 : (int.tryParse(widget.itemData['stock']?.toString() ?? '0') ?? 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E5E25),
        foregroundColor: Colors.white,
        title: Text(isMachinery ? 'Rent Machinery' : 'Place Order'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E5E25).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isMachinery ? Icons.agriculture : Icons.shopping_cart,
                          color: const Color(0xFF2E5E25),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemData['name'] ?? 'Unknown Item',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isMachinery 
                                  ? (widget.itemData['category'] ?? 'Machinery')
                                  : (widget.itemData['type'] ?? 'Product'),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          isMachinery ? 'Price per Day' : 'Price per KG',
                          'Rs. $price',
                        ),
                        if (!isMachinery) ...[
                          const Divider(height: 16),
                          _buildDetailRow('Available Stock', '$stock KG'),
                        ],
                        if (isMachinery && widget.itemData['location'] != null) ...[
                          const Divider(height: 16),
                          _buildDetailRow('Location', widget.itemData['location']),
                        ],
                        if (widget.itemData['quality'] != null) ...[
                          const Divider(height: 16),
                          _buildDetailRow('Quality', widget.itemData['quality']),
                        ],
                        if (isMachinery && widget.itemData['availability'] != null) ...[
                          const Divider(height: 16),
                          _buildDetailRow('Status', widget.itemData['availability']),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quantity/Duration Selector
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMachinery ? 'Rental Duration' : 'Select Quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5E25),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2E5E25), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: isMachinery 
                              ? (days > 1 ? () {
                                  setState(() {
                                    days--;
                                    _updateEndDate();
                                  });
                                } : null)
                              : (quantity > 1 ? () => setState(() => quantity--) : null),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFF2E5E25),
                          iconSize: 32,
                        ),
                        Column(
                          children: [
                            Text(
                              isMachinery ? '$days' : '$quantity',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E5E25),
                              ),
                            ),
                            Text(
                              isMachinery 
                                  ? (days == 1 ? 'Day' : 'Days')
                                  : 'KG',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: isMachinery 
                              ? (days < 30 ? () {
                                  setState(() {
                                    days++;
                                    _updateEndDate();
                                  });
                                } : null)
                              : (quantity < stock ? () => setState(() => quantity++) : null),
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF2E5E25),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Date Selection for Machinery
            if (isMachinery) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Dates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E5E25),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            'Start Date',
                            startDate,
                            () => _selectStartDate(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateSelector(
                            'End Date',
                            endDate,
                            () => _selectEndDate(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            
            // Total Price
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E5E25).withOpacity(0.1),
                    const Color(0xFF4A7C3C).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E5E25).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rs. $totalPrice',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5E25),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5E25),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: const Color(0xFF2E5E25),
                  disabledForegroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isMachinery ? 'Confirm Rent' : 'Confirm Order',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E5E25),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null 
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select Date',
                    style: TextStyle(
                      color: date != null ? Colors.black : Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        startDate = date;
        endDate = date.add(Duration(days: days));
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (startDate == null) {
      AppUtils.showSnackBar(context, 'Please select start date first');
      return;
    }
    
    final date = await showDatePicker(
      context: context,
      initialDate: startDate!.add(Duration(days: days - 1)),
      firstDate: startDate!,
      lastDate: startDate!.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        endDate = date;
        days = date.difference(startDate!).inDays + 1;
      });
    }
  }

  void _confirmOrder() async {
    if (_isLoading) return;
    
    final isMachinery = widget.orderType == OrderType.machinery;
    
    // Validation
    if (isMachinery && days <= 0) {
      AppUtils.showSnackBar(context, 'Please enter a valid number of days (1-30)');
      return;
    }
    
    if (isMachinery && (startDate == null || endDate == null)) {
      AppUtils.showSnackBar(context, 'Please select start and end dates');
      return;
    }
    
    if (!isMachinery && quantity <= 0) {
      AppUtils.showSnackBar(context, 'Please enter a valid quantity (1 or more KG)');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? result;
      
      if (isMachinery) {
        result = await OrderService.createRentalRequest(
          machineryData: widget.itemData,
          days: days,
          startDate: startDate,
          endDate: endDate,
        );
      } else {
        result = await OrderService.createOrder(
          itemData: widget.itemData,
          quantity: quantity,
          orderType: widget.orderType.name,
        );
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        Navigator.pop(context); // Close order screen
        
        if (result != null) {
          final message = isMachinery 
              ? 'Rent request sent! $days ${days == 1 ? 'day' : 'days'} for Rs. ${days * (widget.itemData['pricePerDay'] ?? 0).toInt()}'
              : 'Order placed! $quantity KG for Rs. ${quantity * (widget.itemData['price'] ?? 0).toInt()}';
          
          AppUtils.showSnackBar(context, message);
        } else {
          AppUtils.showSnackBar(context, 'Failed to place order. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }
        AppUtils.showSnackBar(context, errorMessage);
      }
    }
  }
}
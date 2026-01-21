import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/app_utils.dart';

class HireLabourScreen extends StatefulWidget {
  final Map<String, dynamic> labourer;

  const HireLabourScreen({super.key, required this.labourer});

  @override
  State<HireLabourScreen> createState() => _HireLabourScreenState();
}

class _HireLabourScreenState extends State<HireLabourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _durationType = 'Days';
  double _totalAmount = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateAmount);
  }

  void _calculateAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    double rate = 0;
    
    final dailyRate = widget.labourer['dailyRate'] ?? 0.0;
    final hourlyRate = widget.labourer['hourlyRate'] ?? 0.0;
    
    if (_durationType == 'Days') {
      if (dailyRate > 0) {
        rate = dailyRate;
      } else if (hourlyRate > 0) {
        rate = hourlyRate * 8; // 1 day = 8 hours
      }
    } else { // Hours
      if (hourlyRate > 0) {
        rate = hourlyRate;
      } else if (dailyRate > 0) {
        rate = dailyRate / 8; // 1 day = 8 hours
      }
    }
    
    setState(() {
      _totalAmount = quantity * rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hire Labour', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E5E25),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildLabourInfoCard(),
                const SizedBox(height: 16),
                _buildHireDetailsCard(),
                const SizedBox(height: 16),
                _buildAmountCard(),
                const SizedBox(height: 24),
                _buildHireButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabourInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF2E5E25),
                    child: Text(
                      widget.labourer['name']?.toString().substring(0, 1).toUpperCase() ?? 'L',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.labourer['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.labourer['experience'] ?? 'No experience',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('${widget.labourer['rating'] ?? 0.0}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E5E25).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Daily Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Rs. ${widget.labourer['dailyRate'] ?? 0}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E5E25).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('Hourly Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Rs. ${widget.labourer['hourlyRate'] ?? 0}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHireDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F9F1), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hire Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: const Icon(Icons.numbers, color: Color(0xFF2E5E25)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E5E25)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _durationType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF2E5E25)),
                        ),
                      ),
                      items: ['Days', 'Hours'].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _durationType = value!;
                          _calculateAmount();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Work Description',
                  prefixIcon: const Icon(Icons.description, color: Color(0xFF2E5E25)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF2E5E25)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E5E25), Color(0xFF4A7A4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Rs. ${_totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHireButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendHireRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E5E25),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Send Hire Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }

  Future<void> _sendHireRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_quantityController.text.isEmpty) {
      AppUtils.showSnackBar(context, 'Please enter quantity', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sellerId = await AuthService.getUserId();
      if (sellerId == null) return;

      final sellerDoc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      final sellerName = sellerDoc.data()?['name'] ?? 'Farmer';

      await FirebaseFirestore.instance.collection('hire_requests').add({
        'labourId': widget.labourer['userId'],
        'sellerId': sellerId,
        'farmerName': sellerName,
        'labourName': widget.labourer['name'],
        'labourPhone': widget.labourer['phone'],
        'quantity': double.parse(_quantityController.text),
        'durationType': _durationType,
        'description': _descriptionController.text.trim(),
        'totalAmount': _totalAmount,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
        'dailyRate': widget.labourer['dailyRate'],
        'hourlyRate': widget.labourer['hourlyRate'],
      });
      
      print('Saved labourPhone: ${widget.labourer['phone']}');
      print('All labourer data: ${widget.labourer}');

      if (mounted) {
        AppUtils.showSnackBar(context, 'Hire request sent successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Failed to send hire request', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
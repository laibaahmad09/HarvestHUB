import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/services/auth_service.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  
  String? productType, selectedCrop, price, stock, location, variety, unit, quality;
  final cropOptions = ['Wheat', 'Rice', 'Corn', 'Barley', 'Sugarcane'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product Type Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Product Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: productType,
                        items: ['Crop', 'Seed'].map((type) =>
                            DropdownMenuItem(value: type, child: Text(type))
                        ).toList(),
                        onChanged: (val) => setState(() {
                          productType = val;
                          selectedCrop = null;
                        }),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        validator: (val) => val == null ? "Please select type" : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Dynamic sections
              if (productType == 'Crop') _buildCropCard(),
              if (productType == 'Seed') _buildSeedCard(),

              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Add Product", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    try {
      String? userId = await AuthService.getUserId();
      if (userId == null) {
        _showMessage("User not logged in");
        return;
      }

      final collection = productType == 'Crop' ? 'crops' : 'seeds';
      final data = {
        'userId': userId,
        'name': selectedCrop,
        'price': price,
        'stock': stock,
        'location': location,
        'unit': unit,
        'quality': quality,
        'timestamp': FieldValue.serverTimestamp(),
        if (productType == 'Seed') 'variety': variety,
      };

      await FirebaseFirestore.instance.collection(collection).add(data);
      _showMessage("$productType added successfully");
      _resetForm();
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      productType = null;
      selectedCrop = null;
    });
  }

  Widget _buildCropCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Crop Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCrop,
              items: cropOptions.map((crop) =>
                  DropdownMenuItem(value: crop, child: Text(crop))
              ).toList(),
              onChanged: (val) => setState(() => selectedCrop = val),
              decoration: const InputDecoration(
                labelText: "Select Crop",
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null ? "Select a crop" : null,
            ),

            const SizedBox(height: 12),
            _buildTextField("Price per KG", keyboardType: TextInputType.number, onSaved: (val) => price = val),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Stock", keyboardType: TextInputType.number, onSaved: (val) => stock = val)),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Unit", ["KG", "Ton"], (val) => unit = val)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Location", onSaved: (val) => location = val)),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Quality", ["A", "B", "C", "Organic"], (val) => quality = val)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Seed Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTextField("Seed Name", onSaved: (val) => selectedCrop = val),
            const SizedBox(height: 12),
            _buildDropdown("Variety", ["Hybrid 999", "Galaxy 2013", "Punjab 2011"], (val) => variety = val),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField("Price per KG", keyboardType: TextInputType.number, onSaved: (val) => price = val)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Stock", keyboardType: TextInputType.number, onSaved: (val) => stock = val)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDropdown("Unit", ["KG", "Ton"], (val) => unit = val)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField("Location", onSaved: (val) => location = val)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDropdown("Quality", ["A", "B", "C", "Organic"], (val) => quality = val),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {TextInputType? keyboardType, Function(String?)? onSaved}) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val?.isEmpty == true ? "$label is required" : null,
      onSaved: onSaved,
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Select $label" : null,
    );
  }
}
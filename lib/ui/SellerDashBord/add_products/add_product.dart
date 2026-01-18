import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../utils/app_colors.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  
  String? productType, selectedCrop, location, variety, unit, quality;
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final seedNameController = TextEditingController();
  final locationController = TextEditingController();
  final cropOptions = ['Wheat', 'Rice', 'Corn', 'Barley', 'Sugarcane'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E5E25),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.backgroundDecoration,
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Product Type Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.category, color: const Color(0xFF2E5E25), size: 20),
                          const SizedBox(width: 8),
                          const Text("Product Type", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: productType,
                        items: ['Crop', 'Seed'].map((type) =>
                            DropdownMenuItem(value: type, child: Text(type))
                        ).toList(),
                        onChanged: (val) => setState(() {
                          productType = val;
                          selectedCrop = null;
                        }),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              Consumer<ProductController>(
                builder: (context, productController, child) {
                  return ElevatedButton(
                    onPressed: productController.isLoading ? null : _submitProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5E25),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                    ),
                    child: productController.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 8),
                              Text("Add Product", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  );
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final productController = Provider.of<ProductController>(context, listen: false);
    final collection = productType == 'Crop' ? 'crops' : 'seeds';
    
    final data = {
      'name': productType == 'Seed' ? seedNameController.text : selectedCrop,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'stock': int.tryParse(stockController.text) ?? 0,
      'location': locationController.text,
      'unit': unit ?? '',
      'quality': quality ?? '',
      if (productType == 'Seed') 'variety': variety ?? '',
    };

    final success = await productController.addProduct(data, collection);
    
    if (success) {
      _showMessage("$productType added successfully");
      _resetForm();
    } else {
      _showMessage(productController.errorMessage ?? "Failed to add $productType");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    priceController.clear();
    stockController.clear();
    seedNameController.clear();
    locationController.clear();
    setState(() {
      productType = null;
      selectedCrop = null;
      variety = null;
      unit = null;
      quality = null;
    });
  }

  Widget _buildCropCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: const Color(0xFF2E5E25), size: 20),
                const SizedBox(width: 8),
                const Text("Crop Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedCrop,
              items: cropOptions.map((crop) =>
                  DropdownMenuItem(value: crop, child: Text(crop))
              ).toList(),
              onChanged: (val) => setState(() => selectedCrop = val),
              decoration: InputDecoration(
                labelText: "Select Crop",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                ),
              ),
              validator: (val) => val == null ? "Select a crop" : null,
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Price per KG (Rs.)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                ),
              ),
              validator: (val) => val?.isEmpty == true ? "Price is required" : null,
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Stock",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                      ),
                    ),
                    validator: (val) => val?.isEmpty == true ? "Stock is required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Unit", ["KG", "Ton"], (val) => unit = val)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                      ),
                    ),
                    validator: (val) => val?.isEmpty == true ? "Location is required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown("Quality", ["A", "B", "Organic"], (val) => quality = val)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: const Color(0xFF2E5E25), size: 20),
                const SizedBox(width: 8),
                const Text("Seed Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: seedNameController,
              decoration: InputDecoration(
                labelText: "Seed Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                ),
              ),
              validator: (val) => val?.isEmpty == true ? "Seed Name is required" : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown("Variety", ["Hybrid 999", "Galaxy 2013", "Punjab 2011"], (val) => variety = val),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Price per KG (Rs.)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                      ),
                    ),
                    validator: (val) => val?.isEmpty == true ? "Price is required" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Stock",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                      ),
                    ),
                    validator: (val) => val?.isEmpty == true ? "Stock is required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDropdown("Unit", ["KG", "Ton"], (val) => unit = val)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
                      ),
                    ),
                    validator: (val) => val?.isEmpty == true ? "Location is required" : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdown("Quality", ["A", "B", "Organic"], (val) => quality = val),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    priceController.dispose();
    stockController.dispose();
    seedNameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E5E25), width: 2),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "Select $label" : null,
    );
  }
}
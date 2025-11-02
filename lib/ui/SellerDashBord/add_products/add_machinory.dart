import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../controllers/machinery_controller.dart';

class AddMachinery extends StatefulWidget {
  const AddMachinery({super.key});
  @override
  State<AddMachinery> createState() => _AddMachineryState();
}

class _AddMachineryState extends State<AddMachinery> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final contactController = TextEditingController();

  String category = 'Tractor';
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    'Tractor', 'Harvester', 'Plough', 'Cultivator',
    'Thresher', 'Sprayer', 'Seeder',
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Machinery', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Section
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      Text('Add Machinery Photo',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: const Text('Choose Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Form Fields
                _buildTextField(
                  controller: nameController,
                  label: 'Machinery Name',
                  icon: Icons.agriculture,
                  validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),

                _buildDropdown(),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: priceController,
                  label: 'Price per Day (PKR)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty == true ? 'Price is required' : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                  validator: (value) => value?.isEmpty == true ? 'Location is required' : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: contactController,
                  label: 'Contact Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true ? 'Contact is required' : null,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 30),

                // Submit Button
                Consumer<MachineryController>(
                  builder: (context, machineryController, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: machineryController.isLoading ? null : () {
                          if (_formKey.currentState!.validate()) {
                            _saveMachinery();
                          }
                        },
                        child: machineryController.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Add Machinery',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF43A047)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: category,
        decoration: const InputDecoration(
          labelText: 'Category',
          prefixIcon: Icon(Icons.category, color: Color(0xFF43A047)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        items: categories.map((cat) {
          return DropdownMenuItem(
            value: cat,
            child: Text(cat),
          );
        }).toList(),
        onChanged: (val) => setState(() => category = val!),
      ),
    );
  }

  Future<void> _saveMachinery() async {
    final machineryController = Provider.of<MachineryController>(context, listen: false);
    
    String imageBase64 = "";

    // Convert image to Base64 string
    if (selectedImage != null) {
      try {
        List<int> imageBytes = await selectedImage!.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
      } catch (e) {
        print("Exception during Base64 conversion: $e");
      }
    }

    // Save machinery data using controller
    final machineryData = {
      'name': nameController.text,
      'category': category,
      'pricePerDay': double.tryParse(priceController.text) ?? 0,
      'location': locationController.text,
      'contact': contactController.text,
      'description': descriptionController.text,
      'isAvailable': true,
      'imageBase64': imageBase64,
    };

    final success = await machineryController.addMachinery(machineryData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Machinery added successfully!'),
          backgroundColor: const Color(0xFF43A047),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(machineryController.errorMessage ?? 'Failed to add machinery'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    contactController.dispose();
    super.dispose();
  }
}

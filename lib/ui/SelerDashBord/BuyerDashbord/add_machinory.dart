import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_project/services/auth_service.dart';

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
  bool isAvailable = true;
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
                SizedBox(
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Save machinery data including image
                        _saveMachinery();
                      }
                    },
                    child: const Text(
                      'Add Machinery',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
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
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String imageUrl = "";

      // Upload image to Firebase Storage
      if (selectedImage != null) {
        try {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('machinery_images')
              .child('$fileName.jpg');

          UploadTask uploadTask = storageRef.putFile(selectedImage!);
          TaskSnapshot snapshot = await uploadTask;

          // Only get URL if upload was successful
          if (snapshot.state == TaskState.success) {
            imageUrl = await snapshot.ref.getDownloadURL();
            print("Image uploaded URL: $imageUrl");
          } else {
            print("Image upload failed. Task state: ${snapshot.state}");
          }
        } catch (e) {
          print("Exception during upload: $e");
        }
      } else {
        print("No image selected");
      }

      print("Final imageUrl before Firestore save: $imageUrl");

      // Get current user ID
      String? userId = await AuthService.getUserId();
      if (userId == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in"), backgroundColor: Colors.red),
        );
        return;
      }

      // Save machinery data to Firestore
      final machineryData = {
        'userId': userId,
        'name': nameController.text,
        'category': category,
        'pricePerDay': double.tryParse(priceController.text) ?? 0,
        'location': locationController.text,
        'contact': contactController.text,
        'description': descriptionController.text,
        'isAvailable': true,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('machinery').add(machineryData);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Machinery added to Firestore!'),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.pop(context); // Go back after success
    } catch (e) {
      Navigator.of(context).pop(); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/labour_controller.dart';
import '../../../utils/app_utils.dart';

class LabourRegistrationForm extends StatefulWidget {
  final bool isEditing;
  
  const LabourRegistrationForm({super.key, this.isEditing = false});

  @override
  State<LabourRegistrationForm> createState() => _LabourRegistrationFormState();
}

class _LabourRegistrationFormState extends State<LabourRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _rateController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<String> _selectedSkills = [];
  String _availability = 'Full Time';
  String _paymentType = 'Per Day';
  bool _isRegistering = false;
  
  final List<String> _availableSkills = [
    'Crop Harvesting', 'Planting', 'Irrigation', 'Pesticide Application',
    'Machinery Operation', 'Animal Care', 'General Farm Work', 'Organic Farming',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingProfile());
    }
  }

  void _loadExistingProfile() {
    final labourController = Provider.of<LabourController>(context, listen: false);
    final profile = labourController.labourProfile;
    if (profile != null) {
      setState(() {
        _nameController.text = profile['name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _experienceController.text = profile['experience'] ?? '';
        _descriptionController.text = profile['description'] ?? '';
        _selectedSkills = List<String>.from(profile['skills'] ?? []);
        _availability = profile['availability'] ?? 'Full Time';
        
        if (profile['dailyRate'] != null && profile['dailyRate'] > 0) {
          _paymentType = 'Per Day';
          _rateController.text = profile['dailyRate'].toString();
        } else if (profile['hourlyRate'] != null && profile['hourlyRate'] > 0) {
          _paymentType = 'Per Hour';
          _rateController.text = profile['hourlyRate'].toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F9F1), Color(0xFFE8F5E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Personal Information Card
                _buildPersonalInfoCard(),
                const SizedBox(height: 16),
                
                // Skills Card
                _buildSkillsCard(),
                const SizedBox(height: 16),
                
                // Experience & Rates Card
                _buildExperienceCard(),
                const SizedBox(height: 16),
                
                // Availability Card
                _buildAvailabilityCard(),
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _isRegistering ? null : _registerProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5E25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, color: Colors.white),
                            SizedBox(width: 8),
                            Text("Register Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
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
              Row(
                children: [
                  Icon(Icons.person, color: const Color(0xFF2E5E25), size: 20),
                  const SizedBox(width: 8),
                  const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Full Name', Icons.person, validator: (value) => value?.isEmpty == true ? 'Name is required' : null),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone, validator: (value) => value?.isEmpty == true ? 'Phone is required' : null),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address', Icons.location_on, maxLines: 2, validator: (value) => value?.isEmpty == true ? 'Address is required' : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
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
              Row(
                children: [
                  Icon(Icons.build, color: const Color(0xFF2E5E25), size: 20),
                  const SizedBox(width: 8),
                  const Text("Skills & Expertise", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.7),
                    selectedColor: const Color(0xFF2E5E25).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF2E5E25),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceCard() {
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
              Row(
                children: [
                  Icon(Icons.work, color: const Color(0xFF2E5E25), size: 20),
                  const SizedBox(width: 8),
                  const Text("Experience & Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_experienceController, 'Experience (e.g., 5 years)', Icons.work_history, validator: (value) => value?.isEmpty == true ? 'Experience is required' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_rateController, 'Rate (Rs)', Icons.money, keyboardType: TextInputType.number, validator: (value) => value?.isEmpty == true ? 'Rate is required' : null),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _paymentType,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        items: ['Per Day', 'Per Hour'].map((type) {
                          return DropdownMenuItem(
                            value: type, 
                            child: Text(
                              type, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _paymentType = value!),
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

  Widget _buildAvailabilityCard() {
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
              Row(
                children: [
                  Icon(Icons.schedule, color: const Color(0xFF2E5E25), size: 20),
                  const SizedBox(width: 8),
                  const Text("Availability & Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E5E25))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<String>(
                  value: _availability,
                  decoration: const InputDecoration(
                    labelText: 'Availability',
                    prefixIcon: Icon(Icons.schedule, color: Color(0xFF2E5E25)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  items: ['Full Time', 'Part Time', 'Weekends Only', 'Flexible'].map((availability) {
                    return DropdownMenuItem(value: availability, child: Text(availability));
                  }).toList(),
                  onChanged: (value) => setState(() => _availability = value!),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description (Optional)', Icons.description, maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2E5E25)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  void _registerProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkills.isEmpty) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Please select at least one skill', isError: true);
      }
      return;
    }

    setState(() => _isRegistering = true);
    
    final labourController = Provider.of<LabourController>(context, listen: false);
    
    final success = await labourController.registerLabourProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      skills: _selectedSkills,
      experience: _experienceController.text.trim(),
      dailyRate: _paymentType == 'Per Day' ? (double.tryParse(_rateController.text) ?? 0) : 0,
      hourlyRate: _paymentType == 'Per Hour' ? (double.tryParse(_rateController.text) ?? 0) : 0,
      availability: _availability,
      description: _descriptionController.text.trim(),
    );

    if (mounted) {
      setState(() => _isRegistering = false);
      
      if (success) {
        AppUtils.showSnackBar(context, 'Profile registered successfully!');
        Provider.of<LabourController>(context, listen: false).loadLabourProfile();
      } else {
        AppUtils.showSnackBar(context, labourController.errorMessage ?? 'Registration failed', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _rateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
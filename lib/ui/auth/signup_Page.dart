import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Widget/Round_button.dart';
import '../../Widget/role_selecter.dart';
import '../../approutes/app_routes.dart';
import '../../utils/app_utils.dart';
import '../../controllers/auth_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String role = '';
  bool _obscurePassword = true;

  void handleSignup() async {
    if (_formKey.currentState!.validate() && role.isNotEmpty) {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      final success = await authController.signup(
        nameController.text.trim(),
        phoneController.text.trim(),
        addressController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        role,
      );

      if (success) {
        AppUtils.showSnackBar(context, 'Signup successful as $role');
        AppRoutes.navigateAndReplace(context, AppRoutes.login);
      } else {
        AppUtils.showSnackBar(context, authController.errorMessage ?? 'Signup failed', isError: true);
      }
    } else if (role.isEmpty) {
      AppUtils.showSnackBar(context, 'Please select a role', isError: true);
    }
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF4A7A4C)),
      filled: true,
      fillColor: const Color(0xFFE8F5E8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Signup',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3A6B2E)),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: inputDecoration('Full Name', Icons.person),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.number,
                  decoration: inputDecoration('Phone Number', Icons.phone),
                  validator: (value) {
                    final phoneRegex = RegExp(r'^\d{11}$');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (!phoneRegex.hasMatch(value)) {
                      return 'Phone number must be exactly 11 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: addressController,
                  decoration: inputDecoration('Address', Icons.location_on),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your address' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration('Email', Icons.email),
                  validator: (value) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF4A7A4C)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFF4A7A4C),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFE8F5E8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
                    ),
                  ),
                  validator: (value) {
                    final passRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#\$&*~]).{6,12}$');
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (!passRegex.hasMatch(value)) {
                      return 'Password must have 1 capital, 1 small letter, 1 special char';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Role:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3A6B2E)),
                  ),
                ),
                const SizedBox(height: 8),
                RoleSelector(
                  selectedRole: role,
                  onRoleChanged: (value) {
                    setState(() {
                      role = value;
                    });
                  },
                ),
                const SizedBox(height: 25),
                Consumer<AuthController>(
                  builder: (context, authController, child) {
                    return authController.isLoading
                        ? CircularProgressIndicator()
                        : RoundButton(
                            title: 'Sign Up',
                            onTap: handleSignup,
                          );
                  },
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?", style: TextStyle(color: Colors.black)),
                    TextButton(
                      onPressed: () => AppRoutes.navigateTo(context, AppRoutes.login),
                      child: const Text('Login', style: TextStyle(color: Color(0xFF2E5E25), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
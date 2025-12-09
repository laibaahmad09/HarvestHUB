import 'package:first_project/approutes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Widget/Round_button.dart';
import '../../Widget/role_selecter.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_utils.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String role = 'Seller';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  void handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      final success = await authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
        role,
      );

      if (success) {
        if (role == 'Seller') {
          AppRoutes.navigateAndClearStack(context, AppRoutes.sellerDashboard);
        } else if (role == 'Buyer') {
          AppRoutes.navigateAndClearStack(context, AppRoutes.buyerRentMachinery);
        } else if (role == 'Labourer') {
          AppRoutes.navigateAndClearStack(context, AppRoutes.findLabour);
        }
      } else {
        AppUtils.showSnackBar(context, authController.errorMessage ?? 'Login failed', isError: true);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9F1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Welcome to Harvest',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5E25),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 32.0),
                      child: Text(
                        'Choose Your Role',
                        style: TextStyle(fontSize: 16, color: Color(0xFF4A7A4C), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoleSelector(
                    selectedRole: role,
                    onRoleChanged: (value) {
                      setState(() {
                        role = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: Color(0xFF4A7A4C)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFE8F5E8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: const Color(0xFFE8F5E8),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Color(0xFF4A7A4C)),
                      ),
                    ),
                  ),
                  Consumer<AuthController>(
                    builder: (context, authController, child) {
                      return RoundButton(
                        title: 'Login',
                        onTap: authController.isLoading ? null : handleLogin,
                        isLoading: authController.isLoading,
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('― OR ―', style: TextStyle(color: Colors.grey)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 32),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.facebook, color: Color(0xFF3B5998), size: 32),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?", style: TextStyle(color: Colors.black)),
                      TextButton(
                        onPressed: () {
                          AppRoutes.navigateTo(context, AppRoutes.signup);
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Color(0xFF2E5E25), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Empowering Farmers - Growing Together',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
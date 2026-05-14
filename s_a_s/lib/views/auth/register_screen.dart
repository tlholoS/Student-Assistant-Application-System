/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/navigation_service.dart';
import '../../routes/route_constants.dart';
import '../../widgets/premium_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authVM = context.read<AuthViewModel>();
      
      final success = await authVM.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (success && mounted) {
        NavigationService.clearStackAndNavigateTo(RouteConstants.studentHome);
      } else if (mounted && authVM.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVM.errorMessage!), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      body: MeshBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E3192).withOpacity(0.1),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_add_rounded, size: 48, color: Color(0xFF2E3192)),
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: 20),
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ).animate().fadeIn(delay: 200.ms),
                  Text(
                    'Join the Student Assistant Program',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),

                  GlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Names Row
                          Row(
                            children: [
                              Expanded(
                                child: PremiumTextField(
                                  label: 'First Name',
                                  controller: _firstNameController,
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: PremiumTextField(
                                  label: 'Last Name',
                                  controller: _lastNameController,
                                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Email Field
                          PremiumTextField(
                            label: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (!value.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Password Field
                          PremiumTextField(
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            controller: _passwordController,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (value.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Confirm Password Field
                          PremiumTextField(
                            label: 'Confirm Password',
                            prefixIcon: Icons.lock_reset_rounded,
                            controller: _confirmPasswordController,
                            obscureText: true,
                            validator: (value) {
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          
                          // Register Button
                          SizedBox(
                            height: 58,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleRegister,
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                  : const Text('Get Started'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Back to Login
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                ),
                                const Text(
                                  'Login',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3192)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

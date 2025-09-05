import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() => _loading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    String? errorMessage;
    final result = await authService
        .registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          displayName: _nameController.text.trim(),
        )
        .catchError((e) {
          errorMessage = e.toString();
          return null;
        });
    setState(() => _loading = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration successful! Please check your email for verification.',
          ),
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. ${errorMessage ?? ''}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222D36),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFF232D36),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        AppLogoPremium(size: 64),
                        const SizedBox(height: 12),
                        const Text(
                          'Create Your Account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Join Quick Chat today',
                          style: TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2AABEE),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A3441),
                        labelStyle: const TextStyle(color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2AABEE),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A3441),
                        labelStyle: const TextStyle(color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white24,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2AABEE),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A3441),
                        labelStyle: const TextStyle(color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white54,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: 28),
                    _loading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2AABEE),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _register,
                            child: const Text('Register'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              backgroundColor: const Color(0xFF2AABEE),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Already have an account? Login'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2AABEE),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

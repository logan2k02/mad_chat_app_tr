import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final userCredential = await authService.loginWithEmail(
      email: email,
      password: password,
    );
    setState(() => _isLoading = false);
    if (userCredential != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check credentials.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isAuthenticated = authService.currentUserUid != null;
    if (isAuthenticated) {
      Future.microtask(
        () => Navigator.of(context).pushReplacementNamed('/home'),
      );
      return const Center(child: CircularProgressIndicator());
    }
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
                          'Sign in to Quick Chat',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Use your email and password',
                          style: TextStyle(fontSize: 15, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
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
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2AABEE),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Login'),
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
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: const Text('Don\'t have an account? Register'),
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

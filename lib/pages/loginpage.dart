// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'homepage.dart';
import 'registerpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF870005), Color(0xFF4D0005)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon and Title
                const Icon(Icons.login_rounded, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 25),

                // Email Input
                TextField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.mail),
                    labelText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextField(
                  controller: passC,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => obscure = !obscure),
                      child: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Login Button
                ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          final res = await auth.login(emailC.text, passC.text);

                          if (!mounted) return;

                          if (res != null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(res)));
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Homepage(),
                              ),
                            );
                          }
                        },
                  child: auth.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Login"),
                ),

                const SizedBox(height: 15),

                // Navigate to Register
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                  child: const Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

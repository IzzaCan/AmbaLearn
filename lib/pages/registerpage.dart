import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      body: Center(
        child: Container(
          width: 400,
          margin: const EdgeInsets.all(50),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF870005), Color(0xFF4D0005)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 50,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.app_registration, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              const Text(
                "Register",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: userC,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailC,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.mail),
                  labelText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                    child: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final res = await auth.register(
                          userC.text,
                          emailC.text,
                          passC.text,
                        );
                        if (res != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Register successful")),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        }
                      },
                child: auth.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

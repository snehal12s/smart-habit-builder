import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  late AnimationController _animationController;

  String strengthText = "";
  double strength = 0;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    passwordController.addListener(checkStrength);
  }

  void checkStrength() {
    String password = passwordController.text;

    if (password.isEmpty) {
      strength = 0;
      strengthText = "";
    } else if (password.length < 4) {
      strength = 0.3;
      strengthText = "Weak";
    } else if (password.length < 8) {
      strength = 0.6;
      strengthText = "Medium";
    } else {
      strength = 1;
      strengthText = "Strong";
    }
    setState(() {});
  }

  void validateSignup() async {
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      _animationController.forward();

      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Signup failed")),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A0572),
                Color(0xFFC2185B),
                Color(0xFFFF8A65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Create Account ✨",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration("Email", Icons.email),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: inputDecoration("Password", Icons.lock),
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: strength,
                    backgroundColor: Colors.white24,
                    color: strength == 1
                        ? Colors.green
                        : strength == 0.6
                        ? Colors.orange
                        : Colors.red,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    strengthText,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration:
                    inputDecoration("Confirm Password", Icons.lock_outline),
                  ),

                  const SizedBox(height: 30),

                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(_animationController),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A0572),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: validateSignup,
                        child: const Text(
                          "Create Account",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

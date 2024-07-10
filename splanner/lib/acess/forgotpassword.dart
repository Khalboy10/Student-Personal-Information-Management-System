import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password reset link sent! Check  your email'),
            );
          });
      _emailController.clear();
    } on FirebaseAuthException catch (e) {
      print(e);

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });

      _emailController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Enter your email to reset password!",
            style: TextStyle(fontSize: 18),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          ElevatedButton(
            onPressed: () => passwordReset(),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 60, 138, 255))
            ),
            child: const Text('Reset Password', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}

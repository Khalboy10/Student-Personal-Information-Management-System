import 'package:flutter/material.dart';
import 'package:splanner/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Color.fromARGB(255, 60, 138, 255), fontSize: 30)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Image.asset('images/activity.png')),
                const Padding(padding: EdgeInsets.only(top: 30.0)),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const Padding(padding: EdgeInsets.only(top: 30.0)),
                ElevatedButton(
                  onPressed: () => signUpFunc(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 60, 138, 255))
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  String? _validateTextField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> signUpFunc() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        user = userCredential.user;
        await user!.updateDisplayName(_nameController.text);
        await user!.reload();
        user = auth.currentUser;
        if (user != null) {
          Get.to(() => const Home());

          // Clear the text editing controllers
          _nameController.clear();
          _emailController.clear();
          _passwordController.clear();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar(
            'Error',
            'The password provided is too weak.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar(
            'Error',
            'The account already exists for that email.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

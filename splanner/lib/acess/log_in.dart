import 'package:flutter/material.dart';
import 'package:splanner/home.dart';
import 'package:splanner/acess/sign_up.dart';
import 'package:splanner/acess/forgotpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/route_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Color.fromARGB(255, 60, 138, 255), fontSize: 30)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/myBuk.png'),
              const Padding(padding: EdgeInsets.only(top: 15.0)),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              TextButton(onPressed: (){
                Get.to(const ForgotPasswordPage());
                },
                child: const Text("Forgot Password?", style: TextStyle(color: Color.fromARGB(255, 60, 138, 255), fontSize: 18))),
              const SizedBox(height: 5.0),
              ElevatedButton(
                onPressed: () => login(),
                style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 60, 138, 255))
                      ),
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(fontSize: 18)),
                  TextButton(onPressed: (){
                    Get.to(const SignUpPage());
                    },
                    child: const Text("Sign Up", style: TextStyle(color: Color.fromARGB(255, 60, 138, 255), fontSize: 18)))
                  ],
                  )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      user = userCredential.user;
      if (user != null) {
        Get.to(const Home());
        _emailController.clear();
        _passwordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Get.snackbar(
          'Retry',
          'Wrong email or password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print(e);
    }
  }
}


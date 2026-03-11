import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supbase_flutter_coures/component/button.dart';
import 'package:supbase_flutter_coures/component/textformfield.dart';
import 'package:supbase_flutter_coures/services/auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Colors.black87),
      body: ListView(
        children: [
          SizedBox(height: 20),
          FormInput(
            label: "Email",
            hintText: "Enter your email",
            controller: emailController,
          ),
          SizedBox(height: 20),
          FormInput(
            label: "Password",
            hintText: "Enter your password",
            controller: passwordController,
          ),
          SizedBox(height: 20),
          Button(
            label: isLogin ? "Login" : "Sign Up",
            onPressed: () async {
              try {
                if (isLogin) {
                  await AuthSupa().signin(
                    emailController.text,
                    passwordController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logged in successfully!"),
                      duration: Duration(seconds: 2),
                      backgroundColor: const Color.fromARGB(255, 81, 76, 175),
                    ),
                  );
                } else {
                  await AuthSupa().signUp(
                    emailController.text,
                    passwordController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Signed Up successful"),
                      duration: Duration(seconds: 2),
                      backgroundColor: const Color.fromARGB(255, 81, 76, 175),
                    ),
                  );
                }
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "home",
                  (route) => false,
                );
              } catch (e) {
                AwesomeDialog(
                  context: context,
                  title: "Error",
                  body: Text(e.toString()),
                ).show();
              }
            },
          ),

          TextButton(
            onPressed: () {
              isLogin = !isLogin;
              setState(() {});
            },
            child: Text(
              isLogin
                  ? "Don't have an account? Sign Up"
                  : "Already have an account? Login",
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wordle/constants.dart';
import 'package:wordle/screens/login/SignUp.dart';
//import 'package:wordle/screens/login/SignUp.dart';
import 'package:wordle/screens/login/auth_service.dart';
import 'package:wordle/screens/profile.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _SignUpState();
}

class _SignUpState extends State<Login> {
  final _auth = AuthService();

  // late TextEditingController nameController = TextEditingController();
  late TextEditingController mailController = TextEditingController();
  late TextEditingController passController = TextEditingController();
  String verify = "Verify";

  @override
  void dispose() {
    super.dispose();
    mailController.dispose();
    passController.dispose();
    //   nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: loginAppBar(context),
      body: Container(
        color: white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Login",
                style: TextStyle(
                    fontSize: 35, fontWeight: FontWeight.w600, color: grey),
              ),
              const SizedBox(
                height: 30,
              ),
              textField(
                  mailController,
                  const Icon(
                    Icons.mail,
                    color: grey,
                    size: 30,
                  ),
                  "Enter your email",
                  0,
                  TextInputType.emailAddress),
              const SizedBox(
                height: 30,
              ),
              textField(
                  passController,
                  const Icon(
                    Icons.lock,
                    color: grey,
                    size: 30,
                  ),
                  "Password",
                  0,
                  TextInputType.visiblePassword),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Dont have an account?',
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SignUp()));
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            color: darktheme,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: darktheme,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.only(left: 45, right: 45)),
                  onPressed: () {
                    loginuser();
                  },
                  child: Center(
                    child: Text(
                      verify,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginuser() async {
    final user = await _auth.loginUserWithEmailPassword(
      mailController.text,
      passController.text,
    );
    if (user != null) {
      print("User logged in suuccessfully");
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const ProfilePage()));
    }
  }
}

AppBar loginAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: white,
    title: const Row(
      children: [
        Text(
          ' ',
          style: TextStyle(
              fontWeight: FontWeight.w400, color: black, fontSize: 24),
        ),
      ],
    ),
  );
}

Widget textField(TextEditingController contr, Widget icon, String hintext,
    int max, TextInputType inputType) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    height: 60,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: theme, width: 2),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 25),
    child: TextField(
      cursorHeight: 30,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.w400, color: grey),
      controller: contr,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.only(bottom: -2, left: 15, right: 30, top: 10),
        border: InputBorder.none,
        hintText: hintext,
        prefixIcon: icon,
        prefixIconConstraints:
            const BoxConstraints(maxHeight: 15, minWidth: 50),
      ),
      maxLength: max > 0 ? max : null,
      keyboardType: inputType,
    ),
  );
}
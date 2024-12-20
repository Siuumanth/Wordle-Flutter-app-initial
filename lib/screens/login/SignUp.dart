import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wordle/constants/constants.dart';
import 'package:wordle/screens/login/Login.dart';
import 'package:wordle/screens/login/auth_service.dart';
//import 'package:wordle/screens/login/profilepick.dart';
import 'package:wordle/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle/util/widgets/ShowNoti.dart';
import 'package:wordle/wrapper.dart';
import 'package:wordle/model/providers/instances.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _auth = AuthService();
  late TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passController = TextEditingController();
  String verify = "Verify";

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
  }

  Future<void> saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', nameController.text);
    print("Name has been saved");
  }

  Future<bool> doesUserExist() async {
    print(nameController.text.trim());
    if (await Instances.userRef.userNameExists(nameController.text.trim())) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).textTheme.titleMedium!.color!;
    return Scaffold(
      appBar: loginAppBar(context),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Signup",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
                const SizedBox(
                  height: 30,
                ),
                textField(
                    nameController,
                    Icon(
                      Icons.account_circle_sharp,
                      color: textColor,
                      size: 30,
                    ),
                    "Username",
                    0,
                    TextInputType.emailAddress,
                    false,
                    context),
                const SizedBox(
                  height: 30,
                ),
                textField(
                    emailController,
                    Icon(
                      Icons.mail,
                      color: textColor,
                      size: 30,
                    ),
                    "Enter your email",
                    0,
                    TextInputType.emailAddress,
                    false,
                    context),
                const SizedBox(
                  height: 30,
                ),
                textField(
                    passController,
                    Icon(
                      Icons.lock,
                      color: textColor,
                      size: 30,
                    ),
                    "Set password",
                    0,
                    TextInputType.visiblePassword,
                    true,
                    context),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account?',
                        style: TextStyle(fontSize: 17, color: textColor),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Log in',
                          style: TextStyle(
                              color: Theme.of(context).unselectedWidgetColor,
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
                        backgroundColor:
                            Theme.of(context).unselectedWidgetColor,
                        foregroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.only(left: 45, right: 45)),
                    onPressed: () async {
                      if (nameController.text.length < 4) {
                        showTopMessage(
                            context,
                            "Username length must be atleast 4 characters",
                            darktheme,
                            white);
                        return;
                      }
                      if (await doesUserExist()) {
                        print("Username does exist");
                        print(nameController.text);
                        showTopMessage(
                            context, "Username is already in use", red, white);
                        return;
                      }
                      print("Username does not exist");
                      _signup();
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
                ),
                GestureDetector(
                  onTap: () {
                    goToHome(context);
                  },
                  child: Text(
                    "Continue as guest",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).unselectedWidgetColor,
                        decoration: TextDecoration.underline,
                        decorationColor:
                            Theme.of(context).unselectedWidgetColor),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void goToProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void goToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<User?> _signup() async {
    print("start");
    final user = await _auth.createUserWithEmailPassword(
        emailController.text, passController.text);
    print("stop");
    if (user != null) {
      print("User is not null, i am pushing to wrapper");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Wrapper()),
        (Route<dynamic> route) => false,
      );
    } else {
      return null;
    }
    await saveName();
    return user;
  }
}

AppBar loginAppBar(BuildContext context) {
  return AppBar(
    iconTheme: Theme.of(context).iconTheme,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
    int max, TextInputType inputType, bool isPassword, BuildContext context) {
  double screenHeight = MediaQuery.of(context).size.height;
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

      style: TextStyle(
        fontSize: screenHeight / 47,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).textTheme.titleMedium!.color
            : const Color.fromARGB(210, 225, 225, 225),
      ),
      controller: contr,
      obscureText: isPassword, // Hides text for password fields
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.only(bottom: -2, left: 15, right: 30, top: 10),
        border: InputBorder.none,
        hintText: hintext,
        hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).textTheme.titleMedium!.color
                : const Color.fromARGB(211, 212, 212, 212)),
        prefixIcon: icon,
        prefixIconConstraints:
            const BoxConstraints(maxHeight: 15, minWidth: 50),
      ),
      maxLength: hintext == "Username" ? 10 : null,
      keyboardType: isPassword ? TextInputType.visiblePassword : inputType,
    ),
  );
}

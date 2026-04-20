import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // 1️⃣ VARIABLES (state)
  String email = '';
  String password = '';
  bool isLoading = false;

  // 2️⃣ INIT (optional)
  @override
  void initState() {
    super.initState();
  }

  // 3️⃣ FUNCTIONS (logic)
  void handleLogin() async {

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacementNamed(context, '/home');
  }

  void handleFacebook() {}

  void handleGoogle() {}

  void handleApple() {}

  // 4️⃣ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            const SizedBox(height: 150),

            const Text(
              "Welcome back, glad to see you Again!",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            TextField(
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                email = value;
              },
            ),

            const SizedBox(height: 16),

            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                password = value;
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4a7957),
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "---------------------------------- Or Login With ----------------------------------",
                ),
              ],
            ),

            const SizedBox(height: 35),

            Row(
              children: [

                // FACEBOOK BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: handleFacebook,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Icon(Icons.facebook),
                  ),
                ),

                const SizedBox(width: 10),

                // GOOGLE BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: handleGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const FaIcon(FontAwesomeIcons.google),
                  ),
                ),

                const SizedBox(width: 10),

                // APPLE BUTTON
                Expanded(
                  child: OutlinedButton(
                    onPressed: handleApple,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const FaIcon(FontAwesomeIcons.apple),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.register);
                  },
                  child: const Text(
                    "Register now",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}
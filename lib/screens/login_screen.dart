import 'package:flutter/material.dart';

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

    // simple validation
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    // navigate to home
    Navigator.pushReplacementNamed(context, '/home');
  }

  // 4️⃣ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
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

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleLogin,
                      child: const Text("Login"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
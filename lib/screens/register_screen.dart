import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  // 1️⃣ VARIABLES
  String name = '';
  String phone = '';
  String selectedGender = '';
  DateTime? birthday;

  bool isLoading = false;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  // 2️⃣ INIT
  @override
  void initState() {
    super.initState();
  }

  // 3️⃣ FUNCTIONS
  void handleRegister() async {
    if (name.isEmpty || phone.isEmpty || selectedGender.isEmpty || birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Future<void> handlePickBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthday = picked;
      });
    }
  }

  String get formattedBirthday {
    if (birthday == null) return 'Select Birthday';
    return '${birthday!.month}/${birthday!.day}/${birthday!.year}';
  }

  // 4️⃣ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Register",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 20),

              // NAME
              TextField(
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => name = value,
              ),

              const SizedBox(height: 16),

              // PHONE NUMBER
              TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => phone = value,
              ),

              const SizedBox(height: 16),

              // GENDER DROPDOWN
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                value: selectedGender.isEmpty ? null : selectedGender,
                items: genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // BIRTHDAY PICKER
              GestureDetector(
                onTap: handlePickBirthday,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedBirthday,
                        style: TextStyle(
                          fontSize: 16,
                          color: birthday == null ? Colors.grey : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // REGISTER BUTTON
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4a7957),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
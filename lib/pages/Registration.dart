import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedRole = "customer"; // Default role

  void registerUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "name": name,
        "email": email,
        "role": _selectedRole, // Save role (cleaner/customer)
        "uid": userCredential.user!.uid,
      });

      // Update Firebase user profile (optional)
      await userCredential.user!.updateDisplayName(name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful!")),
      );

      Navigator.pushReplacementNamed(context, '/login');
      // Navigate to login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register For System", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black45)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: Colors.lightBlue[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              "Create Your Account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25),

            // Name Input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 15),

            // Email Input
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 15),

            // Password Input
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              obscureText: true,
            ),
            SizedBox(height: 15),

            // Role Selection (Customer or Cleaner)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Role:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Radio(
                      value: "customer",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value.toString();
                        });
                      },
                    ),
                    Text("Customer", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45)),
                    SizedBox(width: 20),
                    Radio(
                      value: "cleaner",
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value.toString();
                        });
                      },
                    ),
                    Text("Cleaner", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 25),

            // Register Button
            ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12,horizontal: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text("Register"),
            ),
            SizedBox(height: 10),

            // Login Navigation
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text("Already have an account? Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45)),
            ),
          ],
        ),
      ),
    );
  }
}

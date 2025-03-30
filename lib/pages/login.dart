import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapp/pages/firstPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Find user role from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection("users").doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        String role = userDoc["role"];

        if (role == "customer") {
          Navigator.pushReplacementNamed(context, '/home_coustomer');
          // Redirect to Customer Home
        } else if (role == "cleaner") {
          Navigator.pushReplacementNamed(context, '/home_cleaner');
          // Redirect to Cleaner Home
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid user role.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User data not found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // This removes the back arrow
        title: Text(
          "Login For System",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => firstPage()),
              );
            },
          ),
        ],
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
              "Welcome Back!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),

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
            SizedBox(height: 20),

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
            SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 40),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text("Login"),
            ),
            SizedBox(height: 10),

            // Register Navigation
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Don't have an account? Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black45)),
            ),
          ],
        ),
      ),
    );
  }
}

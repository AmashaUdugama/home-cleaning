import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen1 extends StatefulWidget {
  @override
  _ProfileScreen1State createState() => _ProfileScreen1State();
}

class _ProfileScreen1State extends State<ProfileScreen1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _user = _auth.currentUser;

    if (_user != null) {
      emailController.text = _user!.email ?? "No Email";

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? "No Name";
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': nameController.text.trim(),
        'email': _user!.email,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 90,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('images/prof2.jpg'),
            ),
            SizedBox(height: 20),
            buildLabel("NAME"),
            buildTextField(nameController),
            SizedBox(height: 20),
            buildLabel("EMAIL"),
            buildTextField(emailController, enabled: false),
            // Email is not editable
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }
}

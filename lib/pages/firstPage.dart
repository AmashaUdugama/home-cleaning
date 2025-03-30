import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapp/pages/login.dart';

class firstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          Image.asset('images/first.jpg',
            fit: BoxFit.cover,),

          Container(
            color: Colors.black.withOpacity(0.3),
          ),


          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Welcome to House Cleaning App",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 15),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Find the best house cleaning services easily!",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),

              Spacer(), // Pushes buttons to bottom

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                label: Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              SizedBox(height: 20),


              ElevatedButton.icon(
                onPressed: () => _logout(context),
                label: Text(
                  "Logout",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.black45,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }

  //  Logout Confirmation
  void _logout(BuildContext context) async {
    bool confirm = await _showLogoutDialog(context);
    if (confirm) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, "/login");
    }
  }


  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog(
      barrierColor: Colors.white38,
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black26),
          ),
        ],
      ),
    ) ??
        false;
  }
}

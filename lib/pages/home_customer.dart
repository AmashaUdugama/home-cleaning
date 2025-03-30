import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileapp/pages/login.dart';
import '../screens/search.dart' show SearchPage;
import '../pages/customer_notification.dart' show CustomerNotificationScreen;
import 'posts.dart';
import 'profile.dart';
import 'review.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  // Track selected tab

  final List<Widget> _pages = [
    HomePageContent(),
    DashboardScreen(),
    UserListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.person_2_rounded,color: Colors.lightBlue,),
        elevation: 0,
        title: Text(
          _selectedIndex == 0 ? " Customer Home" :
          _selectedIndex == 1 ? " House Posts" :
          _selectedIndex == 2 ? " All Reviews" : " User Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),

              );
            },
          ),
        ],
      ),

      body: _pages[_selectedIndex],
      // Load correct screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 5,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.reviews), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

// Home Page Content
class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Image
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/room3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 15),

          // Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      "   Search for ...",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),


          Text(
            "Welcome to Our Service",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),


          Text(
            "Find the Best Cleaning Services",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          //  View Notifications Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerNotificationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                'View Notifications',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),


          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
  }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/customer_notification.dart' show CustomerNotificationScreen;
import '../screens/add_post.dart';
import 'package:firebase_auth/firebase_auth.dart';



class DashboardScreen1 extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection('posts').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No posts available"));
                }

                return ListView(
                  padding: EdgeInsets.all(10),
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final String image = data.containsKey('image') && data['image'] != null
                        ? data['image']
                        : 'https://via.placeholder.com/150'; //

                    final String location = data['location'] ?? 'Unknown';
                    final int rooms = (data['rooms'] is int) ? data['rooms'] : 0;
                    final String date = data['date'] ?? 'N/A';

                    return postItem(context, doc.id, image, location, rooms, date);
                  }).toList(),
                );
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  //  Post items
  Widget postItem(BuildContext context, String postId, String imagePath, String location, int rooms, String date) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.purple.shade50,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location: $location', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Rooms: $rooms'),
                      Text('Date: $date'),
                      Text('Morning / Afternoon', style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User not logged in!"),backgroundColor: Colors.cyan,),
                    );
                    return;
                  }

                  try {
                    // Find user details from Firestore
                    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

                    if (!userDoc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("User details not found in Firestore!"),backgroundColor: Colors.cyan,),
                      );
                      return;
                    }

                    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
                    String senderName = userData?['name'] ?? "Unknown User";
                    String senderEmail = userData?['email'] ?? "Unknown Email";

                    if (location.isEmpty || rooms == 0 || date.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Invalid post details, please check again!"),backgroundColor: Colors.pink,),
                      );
                      return;
                    }

                    await _firestore.collection('notifications').add({
                      'postId': postId,
                      'senderName': senderName,
                      'senderEmail': senderEmail,
                      'location': location,
                      'rooms': rooms,
                      'date': date,
                      'timestamp': FieldValue.serverTimestamp(),
                      'message': "A new request has been sent!",
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Notification sent successfully!"),backgroundColor: Colors.purple,),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to send notification: $e"),backgroundColor: Colors.pink,),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Select", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

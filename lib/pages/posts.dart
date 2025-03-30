import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/add_post.dart';

class DashboardScreen extends StatelessWidget {
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
                        : 'https://via.placeholder.com/150';

                    final String location = data['location'] ?? 'Unknown';
                    final int rooms = (data['rooms'] is int) ? data['rooms'] : 0;
                    final String date = data['date'] ?? 'N/A';

                    return postItem(image, location, rooms, date);
                  }).toList(),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddPostScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
            ),
            child: Text(
              'Add Post',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget postItem(String imagePath, String location, int rooms, String date) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.purple.shade50,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
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
      ),
    );
  }
}

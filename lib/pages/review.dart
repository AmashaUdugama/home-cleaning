import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/add_review.dart' show AddReviewScreen;

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(title: Text("Select Cleaners to Give Reviews"),backgroundColor: Colors.cyan,),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'cleaner').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No cleaners available."));
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];

              return ListTile(
                leading: Icon(Icons.person, color: Colors.blue),
                title: Text(user['name'] ?? "Unnamed Cleaner"),
                subtitle: Text(user['email'] ?? "No Email"),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReviewScreen(cleanerUid: user.id),
                      ),
                    );
                  },
                  child: Text("Review"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

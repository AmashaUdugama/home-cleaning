import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerNotificationScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.yellow,
      ),
      backgroundColor: Colors.blue.shade100,
      body: StreamBuilder(
        stream: _firestore.collection('notifications').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No notifications available"));
          }

          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String senderName = data['senderName'] ?? 'Unknown';
              final String senderEmail = data['senderEmail'] ?? 'Unknown';
              final String location = data['location'] ?? 'Unknown';
              final int rooms = (data['rooms'] is int) ? data['rooms'] : 0;
              final String date = data['date'] ?? 'N/A';
              final String message = data['message'] ?? "No message";
              final Timestamp? timestamp = data['timestamp'];
              final String time = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toString()
                  : "Unknown time";
              final bool isConfirmed = data['status'] == "Confirmed";

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Sender: $senderName", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Email: $senderEmail", style: TextStyle(color: Colors.blue)),
                      Text("Location: $location"),
                      Text("Rooms: $rooms"),
                      Text("Date: $date"),
                      Text("Message: $message"),
                      Text("Time: $time", style: TextStyle(color: Colors.grey.shade700)),
                      Text(
                        "Status: ${isConfirmed ? "Confirmed" : "Pending"}",
                        style: TextStyle(
                          color: isConfirmed ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: isConfirmed
                              ? null
                              : () async {
                            final User? user = _auth.currentUser;
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please log in to confirm jobs!")),
                              );
                              return;
                            }

                            try {
                              await _firestore.collection('notifications').doc(doc.id).update({
                                'status': "Confirmed"
                              });

                              await _firestore.collection('job_confirmations').add({
                                'senderName': senderName,
                                'senderEmail': senderEmail,
                                'location': location,
                                'rooms': rooms,
                                'date': date,
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': "Confirmed",
                                'confirmedBy': user.email, // Track the user
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Job Confirmed Successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to confirm job: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isConfirmed ? Colors.grey : Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Confirm", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

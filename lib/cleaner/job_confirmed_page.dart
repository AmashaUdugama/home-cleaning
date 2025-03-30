import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobConfirmedPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Confirmed"),
        backgroundColor: Colors.yellow,
      ),
      backgroundColor: Colors.blue.shade100,
      body: StreamBuilder(
        stream: _firestore.collection('job_confirmations').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No confirmed jobs available"));
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
              final Timestamp? timestamp = data['timestamp'];
              final String time = timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toString()
                  : "Unknown time";
              final String confirmedBy = data['confirmedBy'] ?? 'Unknown';

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
                      Text("Time: $time", style: TextStyle(color: Colors.grey.shade700)),
                      Text("Confirmed By: $confirmedBy", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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

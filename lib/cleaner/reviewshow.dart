import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class VerifiedUserScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text(" Customer Reviews"),
        backgroundColor: Colors.cyan,
      ),
      body: FutureBuilder<User?>(
        future: Future.value(FirebaseAuth.instance.currentUser),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return Center(child: Text("User not logged in!"));
          }

          User user = userSnapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
                return Center(child: Text("User details not found in Firestore!"),);
              }

              Map<String, dynamic> userData = docSnapshot.data!.data() as Map<String, dynamic>;
              String cleanerEmail = userData['email'] ?? "Unknown Email";

              return FetchCleanerReviews(cleanerEmail: cleanerEmail);
            },
          );
        },
      ),
    );
  }
}

// Find Cleaner Reviews Based on Email
class FetchCleanerReviews extends StatelessWidget {
  final String cleanerEmail;

  FetchCleanerReviews({required this.cleanerEmail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: cleanerEmail)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
          return Center(child: Text("Cleaner not found"));
        }

        // get correct cleaner details
        DocumentSnapshot cleanerDoc = userSnapshot.data!.docs.first;
        String cleanerUid = cleanerDoc.id;
        String cleanerName = cleanerDoc['name'] ?? "Unknown Name";
        String cleanerEmail = cleanerDoc['email'] ?? "Unknown Email";

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(cleanerUid)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.all(10),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  Cleaner Details
                      Text(cleanerName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(cleanerEmail, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      Divider(color: Colors.grey.shade300, thickness: 1, height: 20),

                      //  Reviews Section
                      snapshot.hasData && snapshot.data!.docs.isNotEmpty
                          ? Column(
                        children: snapshot.data!.docs.map((doc) {
                          final reviewData = doc.data() as Map<String, dynamic>?;

                          if (reviewData == null) return SizedBox.shrink();

                          final double rating = (reviewData['rating'] as num?)?.toDouble() ?? 0.0;
                          final String comment = reviewData['comment'] ?? "No comment";
                          final Timestamp? timestamp = reviewData['timestamp'];

                          final String time = timestamp != null
                              ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
                              : "Unknown time";

                          return reviewItem(context, rating, comment, time);
                        }).toList(),
                      )
                          : Center(child: Text("No reviews available", style: TextStyle(fontSize: 19))),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //  Review
  Widget reviewItem(BuildContext context, double rating, String comment, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.comment, color: Colors.blueGrey.shade800, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
                Text(comment, style: TextStyle(fontSize: 14)),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

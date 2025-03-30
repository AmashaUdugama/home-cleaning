import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddReviewScreen extends StatefulWidget {
  final String cleanerUid;

  AddReviewScreen({required this.cleanerUid});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0; // Default rating
  bool _isSubmitting = false; // Track submission status

  void _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a review!"),backgroundColor: Colors.red, ),
      );
      return;
    }

    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to submit a review."),backgroundColor: Colors.red, ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true; // Disable button while submitting
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String reviewText = _reviewController.text.trim();

    try {
      await firestore
          .collection('users')
          .doc(widget.cleanerUid)
          .collection('reviews')
          .add({
        'rating': _rating,
        'comment': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
        'authorId': user.uid,
      });

      await _updateCleanerRating();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review added successfully!"),backgroundColor: Colors.blue, ),
      );

      // Reset UI
      setState(() {
        _reviewController.clear();
        _rating = 3.0;
        _isSubmitting = false;
      });

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $error")),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateCleanerRating() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot reviewSnapshot = await firestore
          .collection('users')
          .doc(widget.cleanerUid)
          .collection('reviews')
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        double avgRating = reviewSnapshot.docs
            .map((doc) => (doc['rating'] as num).toDouble())
            .reduce((a, b) => a + b) /
            reviewSnapshot.docs.length;

        await firestore.collection('users').doc(widget.cleanerUid).update({
          'overallRating': avgRating,
        });
      }
    } catch (error) {
      print("Error updating cleaner rating: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(title: Text("Add Review")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rate this cleaner:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: "Write a review...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              // Disable button while submitting
              child: _isSubmitting ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit Review"),
            ),
          ],
        ),
      ),
    );
  }
}

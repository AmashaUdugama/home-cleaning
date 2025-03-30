import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController locationController = TextEditingController();
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addPost() async {
    String location = locationController.text.trim();
    int rooms = int.tryParse(roomsController.text.trim()) ?? 1;
    String date = dateController.text.trim();
    String imageUrl = imageController.text.trim();

    if (location.isEmpty || date.isEmpty || imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!"),backgroundColor: Colors.pink,),
      );
      return;
    }

    await _firestore.collection('posts').add({
      "location": location,
      "rooms": rooms,
      "date": date,
      "image": imageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Post Added Successfully!"),backgroundColor: Colors.purple,),

    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(title: Text("Add Post")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(

          children: [
            TextField(controller: locationController, decoration: InputDecoration(labelText: "Location")),
            TextField(controller: roomsController, decoration: InputDecoration(labelText: "Number of Rooms")),
            TextField(controller: dateController, decoration: InputDecoration(labelText: "Date")),
            TextField(controller: imageController, decoration: InputDecoration(labelText: "Image URL")),
            SizedBox(height: 25),
            ElevatedButton(onPressed: addPost, child: Text("Submit")),
          ],
        ),
      ),
    );
  }
}

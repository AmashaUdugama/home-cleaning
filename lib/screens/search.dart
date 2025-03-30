import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.blue.shade100,
      body: Column(
        children: [

          //back
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search by location...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),

          Expanded(child: _buildFilteredPosts()),//filtered posts
        ],
      ),
    );
  }

  //display posts
  Widget _buildFilteredPosts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No posts found."));
        }


        var filteredPosts = snapshot.data!.docs.where((doc) {
          String postLocation = doc['location'].toString().toLowerCase();
          // Ensure it's a String
          return _searchQuery.isEmpty || postLocation.contains(_searchQuery);
        }).toList();

        return filteredPosts.isEmpty
            ? Center(child: Text("No posts found for this location."))
            : ListView.builder(
          itemCount: filteredPosts.length,
          itemBuilder: (context, index) {
            var post = filteredPosts[index];

            return _buildPostCard(
              imagePath: post['image'] ?? "",
              location: post['location'] ?? "Unknown Location",
              rooms: post['rooms'].toString(), //  Convert to String
              date: post['date'].toString(),
            );
          },
        );
      },
    );
  }

  // Post
  Widget _buildPostCard({
    required String imagePath,
    required String location,
    required String rooms,
    required String date,
  }) {
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostSearchDelegate extends SearchDelegate {
  PostSearchDelegate();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Enter a search term"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No posts found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!.docs;
        final results = posts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final text = (data["text"] ?? "").toString().toLowerCase();
          final userName = (data["userName"] ?? "").toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return text.contains(searchQuery) || userName.contains(searchQuery);
        }).toList();

        if (results.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No posts found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  "Try different keywords",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, index) {
            final doc = results[index];
            final post = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  post["userName"] ?? "Unknown User",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post["text"] ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text("${(post['likes'] ?? []).length}"),
                        const SizedBox(width: 16),
                        const Icon(Icons.comment, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text("${post['commentCount'] ?? 0}"),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Search posts by content or username",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No posts available"));
        }

        final posts = snapshot.data!.docs;
        final suggestions = posts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final text = (data["text"] ?? "").toString().toLowerCase();
          final userName = (data["userName"] ?? "").toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return text.contains(searchQuery) || userName.contains(searchQuery);
        }).take(5).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (_, index) {
            final doc = suggestions[index];
            final post = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(
                post["userName"] ?? "Unknown User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                post["text"] ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        );
      },
    );
  }
}

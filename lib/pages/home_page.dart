import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_day1/widget/search_deleg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _postTextController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String? _commentPostId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase", ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: PostSearchDelegate());
            },
          ),
          IconButton(
            onPressed: () => _showAddPostBottomSheet(context),
            icon: const Icon(Icons.add),
          ),
        ],backgroundColor: Colors.orangeAccent,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orangeAccent),
              child: Center(
                child: Text(
                  'Flutter Firebase',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            ListTile(
              title: Text("Profile"),
              leading: Icon(Icons.person),
              onTap: (){
                Navigator.of(context).pushNamed("/profile");
              },
            ),
            ListTile(
              title: Text("Sign out"),
              leading: Icon(Icons.logout),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed("/login");
                return;
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet."));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final postId = post.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// User name
                      Text(
                        data['userName'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Post text
                      Text(
                        data['text'] ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 12),

                      /// Like and comment buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Like button
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  (data['likes'] ?? []).contains(FirebaseAuth.instance.currentUser!.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () => toggleLike(postId, data),
                              ),
                              Text('${(data['likes'] ?? []).length} Likes'),
                            ],
                          ),

                          /// Comment count
                          TextButton.icon(
                            onPressed:() => _showCommentBottomSheet(context, postId),
                            icon: const Icon(Icons.comment_outlined),
                            label: Text('${data['commentCount'] ?? 0} Comments'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void toggleLike(String postId, Map<String, dynamic> data) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    final isLiked = (data['likes'] ?? []).contains(userId);

    if (isLiked) {
      postRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      postRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void _showAddPostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _postTextController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Write something...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final text = _postTextController.text.trim();
                if (text.isEmpty) return;

                final currentUser = FirebaseAuth.instance.currentUser;

                final userId = FirebaseAuth.instance.currentUser!.uid;

                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(userId)
                    .get();

                final userData = userDoc.data() as Map<String, dynamic>;

                await FirebaseFirestore.instance.collection('posts').add({
                  'uid': userId,
                  'text': text,
                  'userName': userData["name"] ?? 'anonymous',
                  'likes': [],
                  'commentCount': 0,
                  'createdAt': Timestamp.now(),
                });

                _postTextController.clear();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.send),
              label: const Text("Add Post"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCommentBottomSheet(BuildContext context, String postId) {
    _commentPostId = postId;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Write a comment...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final commentText = _commentController.text.trim();
                if (commentText.isEmpty || _commentPostId == null) return;

                // final currentUser = FirebaseAuth.instance.currentUser;
                // final userId = currentUser!.uid;
                final userId = FirebaseAuth.instance.currentUser!.uid;

                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection("users")
                    .doc(userId)
                    .get();

                final userData = userDoc.data() as Map<String, dynamic>;

                final userName = userData["name"] ?? 'anonymous';

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(_commentPostId)
                    .collection('comments')
                    .add({
                  'text': commentText,
                  'userId': userId,
                  'userName': userName,
                  'createdAt': Timestamp.now(),
                });

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(_commentPostId)
                    .update({
                  'commentCount': FieldValue.increment(1),
                });

                _commentController.clear();
              },
              icon: const Icon(Icons.send),
              label: const Text("Add Comment"),
            ),
            const SizedBox(height: 16),

            /// ✅ Display comments
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .collection('comments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final data = comments[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.comment),
                        title: Text(data['userName'] ?? ''),
                        subtitle: Text(data['text'] ?? ''),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}




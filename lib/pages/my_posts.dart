import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagramexample/components/post_widget.dart';
import 'package:instagramexample/utils/models.dart';

class MyPosts extends StatefulWidget {
  MyPosts(User currentUser, {super.key});

  @override
  MyPostsState createState() => MyPostsState();
}

class MyPostsState extends State<MyPosts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where("user", isEqualTo: currentUser.name)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text('No records');
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (ctx, i) {
              var postData = snapshot.data!.docs[i];
              Post post = Post(
                id: snapshot.data!.docs[i].id,
                user: grootlover,
                imageUrls: List<String>.from(postData.get('imageUrls')),
                location: postData.get('location'),
                postedAt: postData.get('postedAt').toDate(),
              );
              return PostWidget(post);
            },
          );
        });
  }
}

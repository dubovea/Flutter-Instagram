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
          return GridView.builder(
              itemCount: snapshot.data?.docs.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemBuilder: (ctx, i) {
                var postData = snapshot.data!.docs[i],
                    images = List<String>.from(postData.get('imageUrls'));
                Post post = Post(
                  id: snapshot.data!.docs[i].id,
                  user: grootlover,
                  imageUrls: images,
                  location: postData.get('location'),
                  postedAt: postData.get('postedAt').toDate(),
                );
                return Image.network(
                  images[0],
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                );
              });
        });
  }
}

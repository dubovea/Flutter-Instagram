import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagramexample/utils/models.dart';

class MyPostsWidget extends StatefulWidget {
  MyPostsWidget(User currentUser, {super.key});

  @override
  MyPostsWidgetState createState() => MyPostsWidgetState();
}

class MyPostsWidgetState extends State<MyPostsWidget> {
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
                // Post post = Post(
                //   id: snapshot.data!.docs[i].id,
                //   user: grootlover,
                //   imageUrls: images,
                //   location: postData.get('location'),
                //   postedAt: postData.get('postedAt').toDate(),
                // );
                return Image.network(
                  images[0],
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                );
              });
        });
  }
}

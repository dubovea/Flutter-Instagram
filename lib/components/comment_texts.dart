import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagramexample/components/post_widget.dart';
import 'package:instagramexample/utils/models.dart';

import 'comment_widget.dart';

class CommentTexts extends StatefulWidget {
  final docRef;
  const CommentTexts(this.docRef);

  @override
  CommentTextsState createState() => CommentTextsState();
}

class CommentTextsState extends State<CommentTexts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.docRef)
            .collection('comments')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text('No records');
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (ctx, i) {
              final data = snapshot.data!.docs[i];
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(children: [
                    CommentWidget(Comment(
                        commentedAt: data['commentedAt'].toDate(),
                        likes: [],
                        text: data['text'],
                        user: User(name: data['user'], imageUrl: '')))
                  ]),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Column(children: [Text('Комментарии отсутствуют.')]),
              );
            },
          );
        });
  }
}

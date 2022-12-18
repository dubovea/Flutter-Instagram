import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/ui_utils.dart';

class LikesText extends StatefulWidget {
  final docRef;
  const LikesText(this.docRef, {super.key});

  @override
  LikesTextState createState() => LikesTextState();
}

class LikesTextState extends State<LikesText> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.docRef)
            .collection('likes')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text('No records');
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (ctx, i) {
                final data = snapshot.data!.docs;
                if (snapshot.data!.docs.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: <Widget>[
                        const Text('Нравится '),
                        Text(snapshot.data!.docs[0].get('user'), style: bold),
                        if (data.length > 1) ...[
                          const Text(' и еще'),
                          Text(' ${data.length - 1}', style: bold),
                        ]
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(),
                );
              });
        });
  }
}

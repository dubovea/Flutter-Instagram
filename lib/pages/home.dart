import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagramexample/components/avatar_widget.dart';
import 'package:instagramexample/components/post_widget.dart';
import 'package:instagramexample/utils/models.dart';
import 'package:instagramexample/utils/ui_utils.dart';

class Home extends StatelessWidget {
  final ScrollController scrollController;

  const Home({super.key, required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Text('No records');
          }
          return ListView.builder(
            controller: scrollController,
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
              if (i == 0) {
                return Column(children: [StoriesBarWidget(), PostWidget(post)]);
              }
              return PostWidget(post);
            },
          );
        });
  }
}

class StoriesBarWidget extends StatelessWidget {
  final _users = <User>[
    currentUser,
    grootlover,
    rocket,
    nebula,
    starlord,
    gamora,
  ];

  StoriesBarWidget({super.key});

  void _onUserStoryTap(BuildContext context, int i) {
    final message =
        i == 0 ? 'Add to Your Story' : "View ${_users[i].name}'s Story";
    showSnackbar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) {
          return AvatarWidget(
            user: _users[i],
            onTap: () => _onUserStoryTap(context, i),
            radius: 28.0,
            isShowingUsernameLabel: true,
            isCurrentUserStory: i == 0,
          );
        },
        itemCount: _users.length,
      ),
    );
  }
}

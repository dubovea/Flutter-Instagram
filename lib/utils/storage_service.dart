import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:instagramexample/utils/models.dart';

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      firebase_storage.TaskSnapshot snapshot =
          await storage.ref('/instagram_photos/$fileName').putFile(file);
      if (snapshot.state == firebase_storage.TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        FirebaseFirestore.instance.collection('posts').add({
          'post': {
            'user': 'Dubov_EA',
            'imageUrls': [downloadUrl],
            'likes': [],
            'comments': [],
            'postedAt': DateTime.now(),
            'location': 'Surgut'
          }
        });
      } else {
        print('Error link table to image url');
      }
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .delete()
          .then((_) => print('Deleted $id'))
          .catchError((error) => print('Delete failed: $error'));
    } catch (e) {
      print('Delete failed');
    }
  }

  Future<bool> addLike(String id, User user) async {
    bool isLikeAdded = false;
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .set({
            'post': {
              'likes': FieldValue.arrayUnion([
                {'user': user.name}
              ])
            }
          }, SetOptions(merge: true))
          .then((value) => isLikeAdded = true)
          .catchError((error) => print('Error add like for doc $id'));
      return isLikeAdded;
    } catch (e) {
      throw Exception('addLike failed');
    }
  }

  Future<bool> addComment(String id, User user, String comment) async {
    bool isCommentAdded = false;
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .set({
            'post': {
              'comments': FieldValue.arrayUnion([
                {
                  'text': comment,
                  'user': user.name,
                  'commentedAt': DateTime.now(),
                  'likes': []
                }
              ])
            }
          }, SetOptions(merge: true))
          .then((value) => isCommentAdded = true)
          .catchError((error) => print('Error addComent for doc $id'));
      return isCommentAdded;
    } catch (e) {
      throw Exception('addComent failed');
    }
  }

  Future<bool> checkIsLikedBy(String id, User user) async {
    try {
      final snapshot = await FirebaseFirestore.instance
              .collection("posts")
              .doc(id)
              .get(),
          likes = snapshot.data()!['post']['likes'];
      if (likes != null) {
        return likes.any((o) => user.name == o['user']);
      }
      return false;
      // <-- Updated data
    } catch (e) {
      throw Exception('checkIsLikedBy failed');
    }
  }

  Future<bool> removeLike(String id, User user) async {
    bool isLiked = true;
    try {
      final data = await FirebaseFirestore.instance
              .collection("posts")
              .doc(id)
              .get(),
          likes = data.data()!['post']['likes'],
          record = likes.firstWhere((like) => like['user'] == user.name);
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .set({
            'post': {
              'likes': FieldValue.arrayRemove([record])
            }
          }, SetOptions(merge: true))
          .then((_) => isLiked = false)
          .catchError((error) => print('Error remove like for doc $id'));
      return isLiked;
      // <-- Updated data
    } catch (e) {
      throw Exception('removeLike failed');
    }
  },

  Future<bool> removeCommentLike(String id, User user, Comment comment) async {
    bool isLiked = true;
    try {
      final data = await FirebaseFirestore.instance
              .collection("posts")
              .doc(id)
              .get(),
          comments = data.data()!['post']['comments'],
          record = comments.firstWhere((o) => o['user'] == user.name && o['commentedAt'] == comment.commentedAt
           && o['text'] == comment.text);
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .set({
            'post': {
              'comments': {
                'likes': FieldValue.arrayRemove([record])
              }
            }
          }, SetOptions(merge: true))
          .then((_) => isLiked = false)
          .catchError((error) => print('Error remove like for doc $id'));
      return isLiked;
      // <-- Updated data
    } catch (e) {
      throw Exception('removeLike failed');
    }
  }

  Future<bool> addCommentLike(String id, User user, Comment comment) async {
    bool isLiked = true;
    try {
      final data = await FirebaseFirestore.instance
              .collection("posts")
              .doc(id)
              .get(),
          likes = data.data()!['post']['likes'],
          record = likes.firstWhere((like) => like['user'] == user.name);
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .set({
            'post': {
              'likes': FieldValue.arrayRemove([record])
            }
          }, SetOptions(merge: true))
          .then((_) => isLiked = false)
          .catchError((error) => print('Error remove like for doc $id'));
      return isLiked;
      // <-- Updated data
    } catch (e) {
      throw Exception('removeLike failed');
    }
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:instagramexample/utils/models.dart';

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(User user, String filePath, String fileName) async {
    File file = File(filePath);

    try {
      firebase_storage.TaskSnapshot snapshot =
          await storage.ref('/instagram_photos/$fileName').putFile(file);
      if (snapshot.state == firebase_storage.TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        FirebaseFirestore.instance.collection('posts').add({
          'user': user.name,
          'imageUrls': [downloadUrl],
          'postedAt': DateTime.now(),
          'location': 'Surgut'
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
          .then((_) => print('Deleted post $id'))
          .catchError((error) => print('Delete post failed: $error'));
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
          .collection('likes')
          .add({'user': user.name})
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
          .collection('comments')
          .add({
            'text': comment,
            'user': user.name,
            'commentedAt': DateTime.now(),
            'likes': []
          })
          .then((value) => isCommentAdded = true)
          .catchError((error) => print('Error addComent: $error'));
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
              .collection('likes')
              .get(),
          likes = snapshot.docs;
      if (snapshot.docs.length != null) {
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
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(id)
          .collection('likes')
          .where("user", isEqualTo: user.name)
          .get()
          .then((data) async => {
                await FirebaseFirestore.instance
                    .collection("posts")
                    .doc(id)
                    .collection('likes')
                    .doc(data.docs[0].id)
                    .delete()
                    .then((_) => isLiked = false)
                    .catchError((error) => print('Error remove like $error'))
              });
      return isLiked;
      // <-- Updated data
    } catch (e) {
      throw Exception('removeLike failed');
    }
  }

  Future<bool> removeCommentLike(User user, Comment comment) async {
    bool isLiked = true;
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(comment.docRefId)
          .collection('comments')
          .where("user", isEqualTo: comment.user.name)
          .where("text", isEqualTo: comment.text)
          .get()
          .then((data) async => {
                await FirebaseFirestore.instance
                    .collection("posts")
                    .doc(comment.docRefId)
                    .collection('comments')
                    .doc(data.docs[0].id)
                    .set({
                      'likes': FieldValue.arrayRemove([
                        {'user': user.name}
                      ])
                    }, SetOptions(merge: true))
                    .then((_) => isLiked = false)
                    .catchError(
                        (error) => print('Error removeCommentLike $error'))
              });
      return isLiked;
      // <-- Updated data
    } catch (e) {
      throw Exception('removeCommentLike failed');
    }
  }

  Future<bool> addCommentLike(User user, Comment comment) async {
    bool isLiked = false;
    try {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(comment.docRefId)
          .collection('comments')
          .where("user", isEqualTo: comment.user.name)
          .where("text", isEqualTo: comment.text)
          .get()
          .then((data) async => {
                await FirebaseFirestore.instance
                    .collection("posts")
                    .doc(comment.docRefId)
                    .collection('comments')
                    .doc(data.docs[0].id)
                    .set({
                      'likes': FieldValue.arrayUnion([
                        {'user': user.name}
                      ])
                    }, SetOptions(merge: true))
                    .then((_) => isLiked = true)
                    .catchError((error) => print('Error addCommentLike $error'))
              });
      return isLiked;
      // <-- Updated data
    } catch (e) {
      throw Exception('addCommentLike failed');
    }
  }
}

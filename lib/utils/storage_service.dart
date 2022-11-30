import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

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
          'user': 'Dubov_EA',
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
}

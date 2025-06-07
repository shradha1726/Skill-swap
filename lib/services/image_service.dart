import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_pictures/$uid.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadSkillImage(String uid, File imageFile, int index) async {
    final ref = _storage.ref().child('skill_images/${uid}_$index.jpg');
    final uploadTask = ref.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}

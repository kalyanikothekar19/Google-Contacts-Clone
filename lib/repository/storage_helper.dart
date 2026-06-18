import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageHelper {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadPhoto(File file, String contactId) async {
    final ref = _storage.ref().child('contact_photos/$contactId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

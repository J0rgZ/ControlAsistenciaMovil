// lib/services/employee_service.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/empleado.dart';

class EmployeeService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<bool> exists({String? dni, String? email}) async {
    if (dni != null) {
      final q = await _db.collection('employees')
        .where('dni', isEqualTo: dni)
        .get();
      if (q.docs.isNotEmpty) return true;
    }
    if (email != null) {
      final q = await _db.collection('employees')
        .where('email', isEqualTo: email)
        .get();
      if (q.docs.isNotEmpty) return true;
    }
    return false;
  }

  Future<String> uploadPhoto(String dni, File? file, Uint8List? bytes) async {
    final ref = _storage.ref('employees/$dni/face.jpg');
    if (bytes != null) {
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else if (file != null) {
      await ref.putFile(file);
    } else {
      throw Exception('No photo provided');
    }
    return ref.getDownloadURL();
  }

  Future<void> createEmployee(
      Employee emp,
      File? photoFile,
      Uint8List? photoBytes,
  ) async {
    if (await exists(dni: emp.dni)) {
      throw Exception('DNI duplicado');
    }
    if (await exists(email: emp.email)) {
      throw Exception('Email duplicado');
    }

    final photoUrl = await uploadPhoto(emp.dni, photoFile, photoBytes);

    final data = emp.toMap()
      ..['photoUrl']   = photoUrl
      ..['createdAt']  = Timestamp.now();

    await _db
        .collection('employees')
        .doc(emp.dni)
        .set(data);
  }
}

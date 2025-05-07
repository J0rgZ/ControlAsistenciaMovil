import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String dni;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String position;
  final String? siteId;
  final bool isActive;
  final String? photoUrl;         
  final Timestamp? createdAt;      

  Employee({
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.position,
    this.siteId,
    this.photoUrl,     
    this.createdAt,      
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
      'dni': dni,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'position': position,
      'siteId': siteId,
      'isActive': isActive,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (createdAt != null) 'createdAt': createdAt,
      };

  factory Employee.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Employee(
      dni: d['dni'],
      firstName: d['firstName'],
      lastName: d['lastName'],
      phone: d['phone'],
      email: d['email'],
      position: d['position'],
      siteId: d['siteId'],
      photoUrl: d['photoUrl'],
      createdAt: d['createdAt'],
      isActive: d['isActive'] ?? true,
    );
  }
}

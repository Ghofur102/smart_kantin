import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  final String userId;
  final String email;
  final String fullName;
  final String? nim;

  UsersModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.nim,
  });

  // konversi dari object dart ke map untuk dikirim ke firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      if (nim != null) 'nim': nim,
    };
  }

  // konversi dari map ke object dart untuk ditampilkan di flutter dari firebase
  factory UsersModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return UsersModel(
      userId: data['userId'] ?? doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      nim: data['nim'] ?? null,
    );
  }
}

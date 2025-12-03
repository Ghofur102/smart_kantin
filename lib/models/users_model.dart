import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  final String userId;
  final String email;
  final String fullName;
  final String password;

  UsersModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.password,
  });

  // konversi dari object dart ke map untuk dikirim ke firebase
  Map<String, dynamic> toMap_ghofur() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'password': password,
    };
  }

  // konversi dari map ke object dart untuk ditampilkan di flutter dari firebase
  factory UsersModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data_ghofur = doc.data()!;

    return UsersModel(
      userId: data_ghofur['userId'] ?? doc.id,
      email: data_ghofur['email'] ?? '',
      fullName: data_ghofur['fullName'] ?? '',
      password: data_ghofur['password'] ?? '',
    );
  }
}

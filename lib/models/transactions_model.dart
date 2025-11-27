import 'package:cloud_firestore/cloud_firestore.dart';
import 'products_model.dart';

enum Status {
  pending,
  success
}

class TransactionsModel {
  final String trxId;
  final String userId;
  final int totalFinal;
  final Status status;
  final List<ProductsModel> items;

  TransactionsModel({
    required this.trxId,
    required this.userId,
    required this.totalFinal,
    required this.status,
    required this.items
  });

  // konversi dari object dart ke map untuk dikirim ke firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalFinal': totalFinal,
      'status': status,
      'items': items
    };
  }

  // konversi dari map ke object dart untuk ditampilkan di flutter dari firebase
  factory TransactionsModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return TransactionsModel(
      trxId: doc.id, 
      userId: data['userId'] ?? '', 
      totalFinal: data['totalFinal'] ?? '', 
      status: data['status'] ?? '',
      items: data['items'] ?? '',
    );
  }
  
}
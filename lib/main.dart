import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_kantin/firebase_options.dart';
import 'package:smart_kantin/models/products_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi koneksi ke Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // menambahkan product seeder
  await ProductsModel.seederProducts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Kantin',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Referensi Koleksi Firestore
  final CollectionReference _products = FirebaseFirestore.instance.collection(
    'products',
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Kantin')),
      // STREAMBUILDER: Bagian terpenting untuk Real-time
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Kondisi 1: Masih Loading
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Kondisi 2: Data Kosong
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada produk.'));
          }
          // Kondisi 3: Ada Data -> Tampilkan ListView
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    document['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(document['category']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: IconButton(onPressed: () async => {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mencoba mengirim data... Cek Terminal!')),
        ),
        await ProductsModel.seederProducts()
      }, icon: Icon(Icons.add)),
    );
  }
}

// lib/features/farmer/screens/certification_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/request_model.dart';
import '../services/farmer_service.dart';
import '../widgets/status_chip.dart';

class CertificationScreen extends StatefulWidget {
  const CertificationScreen({super.key});

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  final FarmerService _farmerService = FarmerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Sertifikasi Saya'),
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder<List<RequestModel>>(
        // <-- Gunakan StreamBuilder
        stream: _farmerService.getMyCertifications(), // <-- Panggil fungsi baru
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Anda belum mengajukan sertifikasi.'),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  title: Text(
                    request.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    // Format tanggalnya di sini
                    'Diajukan pada: ${DateFormat('d MMMM yyyy', 'id_ID').format(request.submittedDate)}',
                  ),
                  trailing: StatusChip(status: request.status),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-certification');
        },
        label: const Text('Ajukan Baru'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

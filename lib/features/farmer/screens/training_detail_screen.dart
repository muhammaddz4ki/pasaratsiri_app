// lib/features/farmer/screens/training_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/government/models/training_model.dart';
import '../services/farmer_service.dart';

class TrainingDetailScreen extends StatelessWidget {
  final Training training;
  const TrainingDetailScreen({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final FarmerService farmerService = FarmerService();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isQuotaFull =
        training.currentParticipants >= training.maxParticipants;

    void _handleRegistration() async {
      if (currentUser == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final error = await farmerService.registerForTraining(
        trainingId: training.id,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? "Tanpa Nama",
      );

      if (context.mounted) {
        Navigator.pop(context); // Tutup dialog loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error == null
                  ? 'Permintaan pendaftaran terkirim!'
                  : 'Gagal: $error',
            ),
            backgroundColor: error == null ? Colors.green : Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(training.category)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              training.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.person_outline,
                    'Penyelenggara',
                    training.organizer,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Tanggal',
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(training.date.toDate()),
                  ),
                  _buildDetailRow(
                    Icons.access_time_outlined,
                    'Waktu',
                    training.time,
                  ),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Lokasi',
                    training.location,
                  ),
                  _buildDetailRow(
                    Icons.groups_outlined,
                    'Kuota',
                    '${training.currentParticipants} / ${training.maxParticipants} Peserta',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi Pelatihan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    training.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: currentUser == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: farmerService.getRegistrationStatus(
                  trainingId: training.id,
                  userId: currentUser.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ElevatedButton(
                      onPressed: null,
                      child: Text('Memuat Status...'),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.exists) {
                    // Tidak perlu lagi mengambil status, karena kalau dokumennya ada, berarti sudah terdaftar
                    return const ElevatedButton(
                      onPressed: null, // Tombol dimatikan
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Colors.blue,
                        ), // Warna biru untuk status terdaftar
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text('ANDA SUDAH TERDAFTAR'),
                        ],
                      ),
                    );
                  }

                  if (isQuotaFull) {
                    return const ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.grey),
                      ),
                      child: Text('Kuota Pelatihan Penuh'),
                    );
                  }

                  return ElevatedButton(
                    onPressed: _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Daftar Sekarang'),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

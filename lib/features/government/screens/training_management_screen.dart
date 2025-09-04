// lib/features/government/screens/training_management_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/government/models/training_model.dart';
import 'package:pasaratsiri_app/features/government/services/government_service.dart';

class TrainingManagementScreen extends StatefulWidget {
  const TrainingManagementScreen({super.key});

  @override
  State<TrainingManagementScreen> createState() =>
      _TrainingManagementScreenState();
}

class _TrainingManagementScreenState extends State<TrainingManagementScreen> {
  // ... (semua deklarasi variabel state kamu tetap sama di sini)
  final GovernmentService _governmentService = GovernmentService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _timeController = TextEditingController();
  final _dateController = TextEditingController();
  final _imageUrlController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = 'Teknik Budidaya';
  final List<String> _categories = [
    'Teknik Budidaya',
    'Pengolahan Hasil',
    'Pemasaran Digital',
    'Manajemen Keuangan',
    'Teknologi Pertanian',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pelatihan'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTrainingDialog(context),
            tooltip: 'Tambah Pelatihan',
          ),
        ],
      ),
      body: StreamBuilder<List<Training>>(
        stream: _governmentService.getTrainings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/empty_box.png', width: 150),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada pelatihan.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final trainings = snapshot.data!;

          // --- PERBAIKAN DI SINI ---
          // Bungkus Column dengan SingleChildScrollView agar bisa di-scroll
          return SingleChildScrollView(
            child: Column(
              children: [
                // Statistics Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Pelatihan',
                          trainings.length.toString(),
                          Colors.teal[600]!,
                          Icons.school,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Aktif',
                          trainings
                              .where((t) => t.status == 'Aktif')
                              .length
                              .toString(),
                          Colors.blue[600]!,
                          Icons.event_available,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Peserta',
                          trainings
                              .fold<int>(
                                0,
                                (total, t) => total + t.currentParticipants,
                              )
                              .toString(),
                          Colors.green[600]!,
                          Icons.people,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Section
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: 'Semua',
                          decoration: const InputDecoration(
                            labelText: 'Filter Kategori',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          items: ['Semua', ..._categories].map((
                            String category,
                          ) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: 'Semua',
                          decoration: const InputDecoration(
                            labelText: 'Filter Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                          items: ['Semua', 'Aktif', 'Penuh', 'Selesai'].map((
                            String status,
                          ) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {},
                        ),
                      ),
                    ],
                  ),
                ),

                // Training List
                // Gunakan ListView.builder dengan shrinkWrap dan NeverScrollableScrollPhysics
                // karena parent-nya sudah SingleChildScrollView
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trainings.length,
                  itemBuilder: (context, index) {
                    final training = trainings[index];
                    return _buildTrainingCard(training);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Sisa kode dari sini ke bawah tidak perlu diubah ---
  // (Fungsi _buildStatCard, _buildTrainingCard, _showTrainingDetails, dll)

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(Training training) {
    Color statusColor;
    switch (training.status) {
      case 'Aktif':
        statusColor = Colors.green;
        break;
      case 'Penuh':
        statusColor = Colors.orange;
        break;
      case 'Selesai':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.blue;
    }
    final formattedDate = DateFormat(
      'd MMMM yyyy',
    ).format(training.date.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      clipBehavior:
          Clip.antiAlias, // Penting agar gambar tidak keluar dari Card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (training.imageUrl.isNotEmpty)
            Image.network(
              training.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                );
              },
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        training.category,
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        training.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  training.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      training.organizer,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedDate • ${training.time}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        training.location,
                        style: TextStyle(color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: training.maxParticipants > 0
                      ? training.currentParticipants / training.maxParticipants
                      : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    training.currentParticipants >= training.maxParticipants
                        ? Colors.orange
                        : Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${training.currentParticipants}/${training.maxParticipants} peserta',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _showTrainingDetails(training),
                      child: const Text('Detail'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _editTraining(training),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTrainingDetails(Training training) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(training.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  training.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Kategori', training.category),
                _buildDetailItem('Penyelenggara', training.organizer),
                _buildDetailItem(
                  'Tanggal',
                  DateFormat('d MMMM yyyy').format(training.date.toDate()),
                ),
                _buildDetailItem('Waktu', training.time),
                _buildDetailItem('Lokasi', training.location),
                _buildDetailItem(
                  'Kuota',
                  '${training.currentParticipants}/${training.maxParticipants} peserta',
                ),
                _buildDetailItem('Status', training.status),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddTrainingDialog(BuildContext context) {
    _clearForm();
    _selectedCategory = 'Teknik Budidaya';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Pelatihan Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Link Gambar Pelatihan',
                      hintText: 'Contoh: https://i.ibb.co/gambar.jpg',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Link gambar tidak boleh kosong';
                      }
                      if (!v.startsWith('http')) {
                        return 'Link harus valid (diawali http/https)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Pelatihan',
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _organizerController,
                    decoration: const InputDecoration(
                      labelText: 'Penyelenggara',
                    ),
                    validator: (value) => value!.isEmpty
                        ? 'Penyelenggara tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Pelaksanaan',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(dialogContext),
                    validator: (value) =>
                        value!.isEmpty ? 'Tanggal tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Lokasi'),
                    validator: (value) =>
                        value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Waktu (contoh: 09:00 - 15:00)',
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Waktu tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maxParticipantsController,
                    decoration: const InputDecoration(
                      labelText: 'Kuota Maksimal Peserta',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kuota tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addTraining();
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('d MMMM yyyy').format(picked);
      });
    }
  }

  void _addTraining() async {
    if (_selectedDate == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final String? error = await _governmentService.addTraining(
      title: _titleController.text,
      category: _selectedCategory,
      organizer: _organizerController.text,
      date: Timestamp.fromDate(_selectedDate!),
      time: _timeController.text,
      location: _locationController.text,
      maxParticipants: int.parse(_maxParticipantsController.text),
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelatihan berhasil ditambahkan!'),
            backgroundColor: Colors.green,
          ),
        );
        _clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan pelatihan: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editTraining(Training training) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit pelatihan akan segera tersedia'),
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _organizerController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _maxParticipantsController.clear();
    _timeController.clear();
    _dateController.clear();
    _selectedDate = null;
    _imageUrlController.clear();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}

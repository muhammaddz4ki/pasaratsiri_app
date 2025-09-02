import 'package:flutter/material.dart';

class TrainingManagementScreen extends StatefulWidget {
  const TrainingManagementScreen({super.key});

  @override
  State<TrainingManagementScreen> createState() =>
      _TrainingManagementScreenState();
}

class _TrainingManagementScreenState extends State<TrainingManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _organizerController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _timeController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategory = 'Teknik Budidaya';

  final List<String> _categories = [
    'Teknik Budidaya',
    'Pengolahan Hasil',
    'Pemasaran Digital',
    'Manajemen Keuangan',
    'Teknologi Pertanian',
  ];

  final List<Map<String, dynamic>> _trainings = [
    {
      'id': 'TRN001',
      'title': 'Teknik Penyulingan Minyak Atsiri Modern',
      'category': 'Pengolahan Hasil',
      'organizer': 'Dinas Perindustrian Garut',
      'date': '2025-02-15',
      'time': '09:00 - 15:00',
      'location': 'Balai Desa Samarang',
      'maxParticipants': 50,
      'currentParticipants': 35,
      'status': 'Aktif',
      'description':
          'Pelatihan teknik penyulingan modern untuk meningkatkan kualitas dan kuantitas produksi minyak atsiri.',
      'imageUrl': 'assets/training1.jpg',
    },
    {
      'id': 'TRN002',
      'title': 'Pemasaran Digital untuk Produk Atsiri',
      'category': 'Pemasaran Digital',
      'organizer': 'Dinas Koperasi & UMKM',
      'date': '2025-02-20',
      'time': '08:00 - 16:00',
      'location': 'Aula Pemkab Garut',
      'maxParticipants': 30,
      'currentParticipants': 28,
      'status': 'Penuh',
      'description':
          'Workshop pemasaran online, media sosial, dan e-commerce untuk produk minyak atsiri.',
      'imageUrl': 'assets/training2.jpg',
    },
    {
      'id': 'TRN003',
      'title': 'Budidaya Akar Wangi Berkelanjutan',
      'category': 'Teknik Budidaya',
      'organizer': 'Dinas Pertanian Garut',
      'date': '2025-01-28',
      'time': '13:00 - 17:00',
      'location': 'Kebun Demo Pasirwangi',
      'maxParticipants': 40,
      'currentParticipants': 40,
      'status': 'Selesai',
      'description':
          'Pelatihan praktik budidaya akar wangi yang ramah lingkungan dan berkelanjutan.',
      'imageUrl': 'assets/training3.jpg',
    },
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
            onPressed: _showAddTrainingDialog,
            tooltip: 'Tambah Pelatihan',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Pelatihan',
                    _trainings.length.toString(),
                    Colors.teal[600]!,
                    Icons.school,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Aktif',
                    _trainings
                        .where((t) => t['status'] == 'Aktif')
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
                    _trainings
                        .fold(
                          0,
                          (sum, t) => sum + (t['currentParticipants'] as int),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'Semua',
                    decoration: const InputDecoration(
                      labelText: 'Filter Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Semua', ..._categories].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Filter logic would go here
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'Semua',
                    decoration: const InputDecoration(
                      labelText: 'Filter Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Semua', 'Aktif', 'Penuh', 'Selesai'].map((
                      String status,
                    ) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Filter logic would go here
                    },
                  ),
                ),
              ],
            ),
          ),

          // Training List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _trainings.length,
              itemBuilder: (context, index) {
                final training = _trainings[index];
                return _buildTrainingCard(training);
              },
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    Color statusColor;
    switch (training['status']) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
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
                    training['category'],
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
                    training['status'],
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
              training['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  training['organizer'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${training['date']} • ${training['time']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  training['location'],
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value:
                  (training['currentParticipants'] as int) /
                  (training['maxParticipants'] as int),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                (training['currentParticipants'] as int) >=
                        (training['maxParticipants'] as int)
                    ? Colors.orange
                    : Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${training['currentParticipants']}/${training['maxParticipants']} peserta',
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
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainingDetails(Map<String, dynamic> training) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(training['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  training['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Kategori', training['category']),
                _buildDetailItem('Penyelenggara', training['organizer']),
                _buildDetailItem('Tanggal', training['date']),
                _buildDetailItem('Waktu', training['time']),
                _buildDetailItem('Lokasi', training['location']),
                _buildDetailItem(
                  'Kuota',
                  '${training['currentParticipants']}/${training['maxParticipants']} peserta',
                ),
                _buildDetailItem('Status', training['status']),
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
            width: 80,
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

  void _showAddTrainingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pelatihan Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Pelatihan',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul pelatihan harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Kategori'),
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _organizerController,
                    decoration: const InputDecoration(
                      labelText: 'Penyelenggara',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Penyelenggara harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Lokasi'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lokasi harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Waktu (contoh: 09:00 - 15:00)',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Waktu harus diisi';
                      }
                      return null;
                    },
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
                        return 'Kuota peserta harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi harus diisi';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addTraining();
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _addTraining() {
    // Implementation for adding new training
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur tambah pelatihan akan segera tersedia'),
      ),
    );
  }

  void _editTraining(Map<String, dynamic> training) {
    // Implementation for editing training
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit pelatihan akan segera tersedia'),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizerController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

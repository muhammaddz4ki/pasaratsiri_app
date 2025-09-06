import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool _autoBackup = true;
  String _selectedLanguage = 'Bahasa Indonesia';
  String _selectedTheme = 'Sistem';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEA580C), Color(0xFFF97316)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Settings
            _buildSectionTitle('Profil & Akun'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Edit Profil',
                subtitle: 'Ubah informasi profil Anda',
                onTap: () => _showComingSoon(context),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.security,
                title: 'Keamanan',
                subtitle: 'Password & keamanan akun',
                onTap: () => _showComingSoon(context),
              ),
            ]),

            const SizedBox(height: 24),

            // Notification Settings
            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Aktifkan Notifikasi',
                subtitle: 'Terima pemberitahuan aplikasi',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.volume_up_outlined,
                title: 'Suara Notifikasi',
                subtitle: 'Bunyi saat ada notifikasi',
                value: _soundEnabled,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                      }
                    : null,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Getaran',
                subtitle: 'Getar saat ada notifikasi',
                value: _vibrationEnabled,
                onChanged: _notificationsEnabled
                    ? (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                      }
                    : null,
              ),
            ]),

            const SizedBox(height: 24),

            // App Settings
            _buildSectionTitle('Aplikasi'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.language,
                title: 'Bahasa',
                subtitle: _selectedLanguage,
                items: ['Bahasa Indonesia', 'English'],
                selectedValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
              const Divider(height: 1),
              _buildDropdownTile(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: _selectedTheme,
                items: ['Terang', 'Gelap', 'Sistem'],
                selectedValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Data Settings
            _buildSectionTitle('Data & Backup'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.backup,
                title: 'Auto Backup',
                subtitle: 'Backup otomatis data ke cloud',
                value: _autoBackup,
                onChanged: (value) {
                  setState(() {
                    _autoBackup = value;
                  });
                },
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Download data dalam format Excel',
                onTap: () => _showExportDialog(context),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.sync,
                title: 'Sinkronisasi',
                subtitle: 'Sinkron data dengan server',
                onTap: () => _showSyncDialog(context),
              ),
            ]),

            const SizedBox(height: 24),

            // Support Settings
            _buildSectionTitle('Dukungan'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Bantuan',
                subtitle: 'FAQ dan panduan penggunaan',
                onTap: () => _showComingSoon(context),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Kirim Feedback',
                subtitle: 'Berikan masukan untuk aplikasi',
                onTap: () => _showFeedbackDialog(context),
              ),
              const Divider(height: 1),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                subtitle: 'Versi 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ]),

            const SizedBox(height: 32),

            // Danger Zone
            _buildSectionTitle('Zona Bahaya'),
            const SizedBox(height: 16),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.delete_forever,
                title: 'Hapus Semua Data',
                subtitle: 'Hapus seluruh data lokal',
                textColor: const Color(0xFFEF4444),
                onTap: () => _showDeleteDataDialog(context),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFED7AA).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (textColor ?? const Color(0xFFF97316)).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: textColor ?? const Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    final isEnabled = onChanged != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF97316,
              ).withOpacity(isEnabled ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFF97316).withOpacity(isEnabled ? 1 : 0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937).withOpacity(isEnabled ? 1 : 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600]?.withOpacity(isEnabled ? 1 : 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF97316),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFF97316), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButtonFormField<String>(
                  value: selectedValue,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  items: items
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Segera Hadir'),
        content: const Text('Fitur ini akan tersedia dalam update mendatang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Data'),
        content: const Text('Pilih jenis data yang ingin di-export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil di-export!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sinkronisasi Data'),
        content: const Text(
          'Sinkronisasi akan memperbarui data dengan server. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSyncProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
            ),
            child: const Text('Sinkron'),
          ),
        ],
      ),
    );
  }

  void _showSyncProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menyinkronkan data...'),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sinkronisasi berhasil!')));
    });
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Kirim Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Berikan masukan Anda untuk membantu kami meningkatkan aplikasi:',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tulis feedback Anda...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Terima kasih atas feedback Anda!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'PasarAtsiri App',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.business_outlined,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: const [
        Text(
          'Aplikasi manajemen penyulingan minyak atsiri untuk unit penyulingan modern.',
        ),
        SizedBox(height: 16),
        Text('© 2024 PasarAtsiri. All rights reserved.'),
      ],
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Peringatan!'),
          ],
        ),
        content: const Text(
          'Tindakan ini akan menghapus SEMUA data lokal dan tidak dapat dibatalkan. Pastikan Anda telah melakukan backup terlebih dahulu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data telah dihapus!'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}

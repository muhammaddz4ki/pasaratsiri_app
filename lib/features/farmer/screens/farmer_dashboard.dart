import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart';
import 'package:pasaratsiri_app/features/farmer/screens/farmer_chat_list_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/training_list_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/farmer_order_list_screen.dart';
import 'farmer_analytics_screen.dart';
import 'forum_list_screen.dart';

class FarmerDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const FarmerDashboard({super.key, required this.userData});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  bool _showNotificationScreen = false;
  late final List<Widget> _pages;

  // Emerald/Teal Color Palette
  static const Color primaryEmerald = Color(0xFF10B981); // Emerald-500
  static const Color secondaryTeal = Color(0xFF14B8A6); // Teal-500
  static const Color darkEmerald = Color(0xFF047857); // Emerald-700
  static const Color lightEmerald = Color(0xFFD1FAE5); // Emerald-100
  static const Color ultraLightEmerald = Color(0xFFECFDF5); // Emerald-50
  static const Color mediumEmerald = Color(0xFF059669); // Emerald-600

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      _buildHomeScreen(context),
      const TrainingListScreen(),
      const FarmerChatListScreen(),
      _buildProfileScreen(context),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _showNotificationScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBody: true,
      appBar: _buildAppBar(),
      body: _showNotificationScreen
          ? _buildNotificationScreen()
          : _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      centerTitle: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryEmerald, mediumEmerald, darkEmerald],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryEmerald.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wb_sunny, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                '28°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _showNotificationScreen = true;
            });
          },
          icon: Icon(Icons.notifications, color: Colors.white, size: 24),
          padding: const EdgeInsets.only(right: 16, top: 8),
        ),
      ],
    );
  }

  String _getAppBarTitle() {
    if (_showNotificationScreen) {
      return "Notifikasi";
    }
    switch (_selectedIndex) {
      case 0:
        return "Dashboard Petani";
      case 1:
        return "Pusat Pelatihan";
      case 2:
        return "Pesan Masuk";
      case 3:
        return "Profil Saya";
      default:
        return "Dashboard Petani";
    }
  }

  Widget _buildHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 24),
          _buildSummarySection(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildMainMenu(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, ultraLightEmerald, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: lightEmerald.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryEmerald, mediumEmerald]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.6),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.agriculture, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.userData['name'] ?? 'Petani Atsiri',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkEmerald,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lightEmerald,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Petani Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: darkEmerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ultraLightEmerald, Colors.white, ultraLightEmerald],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: lightEmerald.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Harga', 'Stabil', Icons.trending_up, mediumEmerald),
          _summaryItem('Produksi', '12 Ton', Icons.eco, Colors.blue.shade600),
          _summaryItem(
            'Sertifikasi',
            '1 Aktif',
            Icons.shield,
            Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Akses Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Fix overflow dengan SingleChildScrollView
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 8), // Padding awal
              _quickActionCard(
                'Catat Panen',
                Icons.agriculture,
                mediumEmerald,
                () => _showHarvestDialog(),
              ),
              _quickActionCard(
                'Cek Cuaca',
                Icons.cloud,
                Colors.blue.shade600,
                () => _showWeatherDialog(),
              ),
              _quickActionCard(
                'Kalkulator',
                Icons.calculate,
                Colors.orange.shade600,
                () => _showCalculatorDialog(),
              ),
              _quickActionCard(
                'Lacak Order',
                Icons.local_shipping,
                Colors.purple.shade600,
                () => _showTrackingDialog(),
              ),
              _quickActionCard(
                'Pengingat',
                Icons.notifications_active,
                Colors.red.shade600,
                () => _showReminderDialog(context),
              ),
              const SizedBox(width: 8), // Padding akhir
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: 110,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 3,
        shadowColor: color.withOpacity(0.3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildEnhancedCard(
              icon: Icons.inventory_2_outlined,
              title: 'Produk Saya',
              color: mediumEmerald,
              onTap: () => Navigator.pushNamed(context, '/product-list'),
            ),
            _buildEnhancedCard(
              icon: Icons.price_change_outlined,
              title: 'Info Harga Pasar',
              color: Colors.orange.shade600,
              onTap: () => Navigator.pushNamed(context, '/market-price'),
            ),
            _buildEnhancedCard(
              icon: Icons.verified_outlined,
              title: 'Sertifikasi',
              color: Colors.blue.shade600,
              onTap: () => Navigator.pushNamed(context, '/certification'),
            ),
            _buildEnhancedCard(
              icon: Icons.savings_outlined,
              title: 'Bantuan & Subsidi',
              color: Colors.purple.shade600,
              onTap: () => Navigator.pushNamed(context, '/subsidy'),
            ),
            _buildEnhancedCard(
              icon: Icons.receipt_long_outlined,
              title: 'Pesanan Masuk',
              color: secondaryTeal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerOrderListScreen(),
                  ),
                );
              },
            ),
            _buildEnhancedCard(
              icon: Icons.analytics_outlined,
              title: 'Dashboard Analitik',
              color: Colors.indigo.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerAnalyticsScreen(),
                  ),
                );
              },
            ),
            _buildEnhancedCard(
              icon: Icons.forum_outlined,
              title: 'Forum Diskusi',
              color: Colors.lightBlue.shade600,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForumListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, color.withOpacity(0.05), Colors.white],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(-3, -3),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifikasi Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _notificationItem(
                  'Harga Minyak Atsiri Naik',
                  'Harga minyak vetiver naik 5% hari ini',
                  Icons.trending_up,
                  mediumEmerald,
                  '2 jam lalu',
                ),
                _notificationItem(
                  'Bantuan Subsidi Tersedia',
                  'Program subsidi pupuk telah dibuka',
                  Icons.savings,
                  Colors.blue.shade600,
                  '5 jam lalu',
                ),
                _notificationItem(
                  'Pelatihan Online Baru',
                  'Teknik penyulingan modern tersedia',
                  Icons.school,
                  Colors.orange.shade600,
                  '1 hari lalu',
                ),
                _notificationItem(
                  'Cuaca Buruk Peringatan',
                  'Hujan lebat diprediksi 3 hari ke depan',
                  Icons.cloud_queue,
                  Colors.red.shade600,
                  '2 hari lalu',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(
    String title,
    String description,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primaryEmerald, mediumEmerald]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryEmerald.withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            widget.userData['name'] ?? 'Petani',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.userData['email'] ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 40),
          _profileMenuItem('Edit Profil', Icons.edit, () {}),
          _profileMenuItem('Pengaturan', Icons.settings, () {}),
          _profileMenuItem('Bantuan', Icons.help, () {}),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _profileMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: mediumEmerald),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryEmerald.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 15,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: Colors.grey.shade300.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(8, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_filled, Icons.home_outlined, 'Home'),
          _buildNavItem(1, Icons.school, Icons.school_outlined, 'Pelatihan'),
          _buildNavItem(
            2,
            Icons.chat_bubble,
            Icons.chat_bubble_outline,
            'Pesan',
          ),
          _buildNavItem(3, Icons.person, Icons.person_outline, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    primaryEmerald.withOpacity(0.2),
                    mediumEmerald.withOpacity(0.1),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryEmerald.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? darkEmerald : Colors.grey.shade600,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? darkEmerald : Colors.grey.shade600,
                fontSize: isSelected ? 13 : 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMPROVED DIALOGS
  void _showHarvestDialog() {
    final harvestController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, ultraLightEmerald],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryEmerald, mediumEmerald],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryEmerald.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.agriculture, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Catat Hasil Panen',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: harvestController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Panen (kg)',
                  prefixIcon: Icon(Icons.scale, color: primaryEmerald),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal Panen',
                  prefixIcon: Icon(Icons.calendar_today, color: primaryEmerald),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: primaryEmerald,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    dateController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (harvestController.text.isNotEmpty &&
                            dateController.text.isNotEmpty) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Data panen berhasil disimpan'),
                              backgroundColor: mediumEmerald,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryEmerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeatherDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue.shade50],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Info Cuaca Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Icon(Icons.wb_sunny, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              Text(
                'Cerah Berawan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Suhu: 28°C',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelembaban: 65%',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Curah Hujan: 0 mm',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalculatorDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.orange.shade50],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.orange.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calculate, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Kalkulator Pupuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Fitur ini akan segera hadir!',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrackingDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.purple.shade50],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_shipping, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Lacak Pesanan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Fitur ini akan segera hadir!',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    bool isNotificationEnabled = true;
    final reminderTypeController = TextEditingController();
    final dateTimeController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.red.shade50.withOpacity(0.3)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade400],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Atur Pengingat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reminder type dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Jenis Pengingat',
                        prefixIcon: Icon(
                          Icons.category,
                          color: Colors.red.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items:
                          [
                            'Waktu Panen',
                            'Penyiraman',
                            'Pemupukan',
                            'Pengecekan Hama',
                            'Penyulingan',
                            'Lainnya',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        reminderTypeController.text = newValue ?? '';
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Pengingat',
                        prefixIcon: Icon(
                          Icons.description,
                          color: Colors.red.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintText: 'Contoh: Saatnya panen vetiver di lahan A',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date time input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: TextField(
                      controller: dateTimeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal & Waktu',
                        prefixIcon: Icon(
                          Icons.schedule,
                          color: Colors.red.shade600,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.calendar_today,
                            color: Colors.red.shade600,
                          ),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.red.shade600,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.red.shade600,
                                            onPrimary: Colors.white,
                                            surface: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                              if (pickedTime != null) {
                                final DateTime selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                dateTimeController.text =
                                    "${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} ${selectedDateTime.hour}:${selectedDateTime.minute.toString().padLeft(2, '0')}";
                              }
                            }
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notification toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Aktifkan Notifikasi',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Switch(
                          value: isNotificationEnabled,
                          onChanged: (value) {
                            setState(() {
                              isNotificationEnabled = value;
                            });
                          },
                          activeColor: Colors.red.shade600,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (dateTimeController.text.isNotEmpty) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pengingat berhasil disimpan'),
                                  backgroundColor: mediumEmerald,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.red.shade50.withOpacity(0.3)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade300],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Konfirmasi Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Icon(Icons.help_outline, color: Colors.grey.shade600, size: 48),
                const SizedBox(height: 16),

                Text(
                  'Apakah Anda yakin ingin keluar dari akun ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          AuthService().signOut().then((_) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

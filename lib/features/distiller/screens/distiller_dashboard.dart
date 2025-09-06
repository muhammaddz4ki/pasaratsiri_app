import 'package:flutter/material.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart';
import 'package:pasaratsiri_app/features/distiller/screens/distillation_input_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/product_distribution_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/product_quality_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/analytics_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/inventory_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/notification_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/settings_screen.dart';
import 'package:pasaratsiri_app/features/distiller/screens/farmer_locations_screen.dart';

class UnitPenyulinganDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UnitPenyulinganDashboard({super.key, required this.userData});

  @override
  State<UnitPenyulinganDashboard> createState() =>
      _UnitPenyulinganDashboardState();
}

class _UnitPenyulinganDashboardState extends State<UnitPenyulinganDashboard>
    with TickerProviderStateMixin {
  int _selectedIndex = 2; // Default to Home
  late final List<Widget> _pages;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _pages = <Widget>[
      _buildAnalyticsScreen(context),
      const FarmerLocationsScreen(),
      _buildHomeScreen(context),
      _buildNotificationScreen(context),
      _buildProfileScreen(context),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5), // Orange-25 background
      appBar: _selectedIndex != 4
          ? AppBar(
              title: Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFEA580C), // Orange-600
                      Color(0xFFF97316), // Orange-500
                      Color(0xFFFB923C), // Orange-400
                      Color(0xFFFF8C00), // Deep Orange
                    ],
                    stops: [0.0, 0.4, 0.8, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF97316),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFED7AA), // Orange-200
              Color(0xFFFED7AA), // Orange-200
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: -10,
              offset: const Offset(-5, 0),
            ),
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: -10,
              offset: const Offset(5, 0),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 10,
              spreadRadius: -5,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFED7AA).withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF9F5), // Very light orange
                Colors.white,
                Color(0xFFFFF7ED), // Orange-50
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFFEA580C), // Orange-600
              unselectedItemColor: const Color(0xFF9CA3AF),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: _selectedIndex == 0
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFEA580C), // Orange-600
                                Color(0xFFF97316), // Orange-500
                              ],
                            )
                          : null,
                      color: _selectedIndex == 0 ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: _selectedIndex == 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _selectedIndex == 0
                          ? Icons.analytics
                          : Icons.analytics_outlined,
                      size: 26,
                      color: _selectedIndex == 0
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  label: "Analitik",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: _selectedIndex == 1
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFEA580C), // Orange-600
                                Color(0xFFF97316), // Orange-500
                              ],
                            )
                          : null,
                      color: _selectedIndex == 1 ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: _selectedIndex == 1
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _selectedIndex == 1 ? Icons.map : Icons.map_outlined,
                      size: 26,
                      color: _selectedIndex == 1
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  label: "Lokasi",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedIndex == 2
                          ? const Color(0xFFEA580C).withOpacity(0.2)
                          : Colors.transparent,
                      boxShadow: _selectedIndex == 2
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      _selectedIndex == 2 ? Icons.home : Icons.home_outlined,
                      size: 40,
                      color: _selectedIndex == 2
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: _selectedIndex == 3
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFEA580C), // Orange-600
                                Color(0xFFF97316), // Orange-500
                              ],
                            )
                          : null,
                      color: _selectedIndex == 3 ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: _selectedIndex == 3
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          _selectedIndex == 3
                              ? Icons.notifications
                              : Icons.notifications_outlined,
                          size: 26,
                          color: _selectedIndex == 3
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                        ),
                        if (_selectedIndex != 3)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  label: "Notifikasi",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: _selectedIndex == 4
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFEA580C), // Orange-600
                                Color(0xFFF97316), // Orange-500
                              ],
                            )
                          : null,
                      color: _selectedIndex == 4 ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: _selectedIndex == 4
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF97316).withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _selectedIndex == 4 ? Icons.person : Icons.person_outline,
                      size: 26,
                      color: _selectedIndex == 4
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  label: "Profil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Analitik & Laporan';
      case 1:
        return 'Lokasi Petani';
      case 2:
        return 'Dashboard Penyulingan';
      case 3:
        return 'Notifikasi';
      case 4:
        return 'Profil';
      default:
        return 'Dashboard Penyulingan';
    }
  }

  Widget _buildHomeScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context: context,
              icon: Icons.add_chart,
              title: 'Input Penyulingan',
              subtitle: 'Catat proses & hasil penyulingan baru.',
              color: const Color(0xFFF97316),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DistillationInputScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.verified_user_outlined,
              title: 'Manajemen Mutu Produk',
              subtitle: 'Upload hasil uji lab & lihat status verifikasi.',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductQualityScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.local_shipping_outlined,
              title: 'Distribusi Produk',
              subtitle: 'Atur batch minyak yang siap untuk dijual.',
              color: const Color(0xFFFB923C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductDistributionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.inventory_2_outlined,
              title: 'Manajemen Stok',
              subtitle: 'Kelola inventori bahan baku & produk jadi.',
              color: const Color(0xFF10B981),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              context: context,
              icon: Icons.settings_outlined,
              title: 'Pengaturan Sistem',
              subtitle: 'Konfigurasi & pengaturan aplikasi.',
              color: const Color(0xFF6B7280),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFED7AA), // Orange-200
            Color(0xFFFEDCBF), // Lighter orange
            Colors.white,
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: -3,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFED7AA).withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.userData['name'] ?? 'Pengguna',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA580C),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF97316), // Orange-500
                      Color(0xFFEA580C), // Orange-600
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: const Color(0xFFEA580C).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              '● Online - Sistem Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Hari Ini',
            value: '12',
            subtitle: 'Batch Selesai',
            icon: Icons.today,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Minggu Ini',
            value: '89',
            subtitle: 'Total Batch',
            icon: Icons.trending_up,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Stok',
            value: '245L',
            subtitle: 'Siap Jual',
            icon: Icons.inventory,
            color: const Color(0xFFF97316),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 15,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 25,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFFFFAF5), // Orange-25
            Color(0xFFFFF9F5),
            Colors.white,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: -8,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.12), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: -3,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.12),
                        color.withOpacity(0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsScreen(BuildContext context) {
    return const AnalyticsScreen();
  }

  Widget _buildNotificationScreen(BuildContext context) {
    return const NotificationScreen();
  }

  Widget _buildProfileScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFFED7AA), // Orange-200
                  Color(0xFFFEDCBF), // Lighter orange
                  Colors.white,
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: -3,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.orange.withOpacity(0.08),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFFED7AA).withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF97316), // Orange-500
                        Color(0xFFEA580C), // Orange-600
                        Color(0xFFDC2626), // Red accent
                      ],
                      stops: [0.0, 0.7, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF97316).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFEA580C).withOpacity(0.2),
                        blurRadius: 25,
                        spreadRadius: -3,
                        offset: const Offset(0, 15),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.business_outlined,
                    size: 45,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.userData['name'] ?? 'Unit Penyulingan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.userData['email'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF97316), // Orange-500
                  Color(0xFFEA580C), // Orange-600
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFFEA580C).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -3,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'PENGATURAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -3,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'LOGOUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFFFFAF5), // Orange-25
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 48,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Konfirmasi Logout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Apakah Anda yakin ingin keluar dari aplikasi?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await AuthService().signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shadowColor: Colors.redAccent.withOpacity(0.4),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
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

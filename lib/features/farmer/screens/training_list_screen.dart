// lib/features/farmer/screens/training_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/government/models/training_model.dart';
import '../services/farmer_service.dart';
import 'training_detail_screen.dart';

class TrainingListScreen extends StatelessWidget {
  const TrainingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FarmerService farmerService = FarmerService();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFECFDF5), // Emerald-50
              Color(0xFFFAFAFA), // Light grey
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: StreamBuilder<List<Training>>(
          stream: farmerService.getAvailableTrainings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final trainings = snapshot.data!;
            return _buildTrainingList(context, trainings);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A10B981),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat pelatihan...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A10B981),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x2610B981),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Pelatihan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada pelatihan yang tersedia saat ini.\nSilakan coba lagi nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingList(BuildContext context, List<Training> trainings) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header dengan judul halaman
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          expandedHeight: 100, // Diperkecil dari 120
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: Text(
              'Pelatihan Tersedia',
              style: TextStyle(
                fontSize: 22, // Diperkecil dari 28
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(0, 1),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Grid untuk daftar pelatihan
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 500, // Lebar maksimum kartu
              mainAxisExtent: 320, // Tinggi tetap untuk konsistensi
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio:
                  1, // Menghapus childAspectRatio karena menggunakan mainAxisExtent
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final training = trainings[index];
              return _buildTrainingCard(context, training, index);
            }, childCount: trainings.length),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingCard(
    BuildContext context,
    Training training,
    int index,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFAFAFA)],
          ),
          boxShadow: [
            // Main shadow
            BoxShadow(
              color: const Color(0x1A10B981),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            // Subtle inner glow
            BoxShadow(
              color: const Color(0x0510B981),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TrainingDetailScreen(training: training),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ),
                          ),
                          child: child,
                        );
                      },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: Image.network(
                            training.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF10B981),
                                        Color(0xFF14B8A6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.school_outlined,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                        // Category Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              training.category,
                              style: const TextStyle(
                                color: Color(0xFF047857),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          training.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // Date Section
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD1FAE5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  DateFormat(
                                    'd MMMM yyyy',
                                    'id_ID',
                                  ).format(training.date.toDate()),
                                  style: const TextStyle(
                                    color: Color(0xFF047857),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

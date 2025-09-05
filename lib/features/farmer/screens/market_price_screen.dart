// lib/features/farmer/screens/market_price_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/farmer/services/farmer_service.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({super.key});

  @override
  State<MarketPriceScreen> createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen>
    with TickerProviderStateMixin {
  final FarmerService _farmerService = FarmerService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildPriceCard(MarketPriceModel item, int index) {
    final Icon trendIcon;
    final Color trendColor;
    final String trendText;
    final double priceDifference = (item.currentPrice - item.previousPrice)
        .toDouble(); // FIXED: Added .toDouble()
    final double percentageChange = item.previousPrice != 0
        ? (priceDifference / item.previousPrice) * 100
        : 0;

    if (item.currentPrice > item.previousPrice) {
      trendIcon = const Icon(Icons.trending_up_rounded, size: 28);
      trendColor = const Color(0xFF059669); // Green-600
      trendText = '+${percentageChange.toStringAsFixed(1)}%';
    } else if (item.currentPrice < item.previousPrice) {
      trendIcon = const Icon(Icons.trending_down_rounded, size: 28);
      trendColor = const Color(0xFFDC2626); // Red-600
      trendText = '${percentageChange.toStringAsFixed(1)}%';
    } else {
      trendIcon = const Icon(Icons.trending_flat_rounded, size: 28);
      trendColor = const Color(0xFF6B7280); // Gray-500
      trendText = '0.0%';
    }

    final formattedPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(item.currentPrice);

    final formattedDifference = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(priceDifference.abs());

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: Offset(0, 0.5 + (index * 0.1)),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    1.0,
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  (index * 0.1).clamp(0.0, 1.0),
                  1.0,
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFF0FDF4), // Green-50
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFD1FAE5).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Add tap action if needed
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Commodity Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.commodity,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$formattedPrice/kg',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: trendColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: trendColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.currentPrice > item.previousPrice
                                          ? Icons.arrow_upward_rounded
                                          : item.currentPrice <
                                                item.previousPrice
                                          ? Icons.arrow_downward_rounded
                                          : Icons.remove_rounded,
                                      color: trendColor,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      trendText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: trendColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Trend Icon & Price Change
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: trendColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: trendColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                item.currentPrice > item.previousPrice
                                    ? Icons.trending_up_rounded
                                    : item.currentPrice < item.previousPrice
                                    ? Icons.trending_down_rounded
                                    : Icons.trending_flat_rounded,
                                color: trendColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (priceDifference != 0)
                              Text(
                                '±$formattedDifference',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFF14B8A6).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                size: 64,
                color: const Color(0xFF10B981).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data Harga Tidak Tersedia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Informasi harga pasar sedang tidak tersedia\nsaat ini. Coba lagi nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    setState(() {
                      _animationController.reset();
                      _animationController.forward();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Muat Ulang',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Colors.red.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF047857)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF047857),
                      Color(0xFF10B981),
                      Color(0xFF14B8A6),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text(
                'Informasi Harga Pasar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              centerTitle: true,
            ),
          ),

          // Header Info Card
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, const Color(0xFFECFDF5)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga Pasar Terkini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pantau pergerakan harga komoditas',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF047857),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: StreamBuilder<List<MarketPriceModel>>(
              stream: _farmerService.getMarketPricesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF10B981).withOpacity(0.1),
                                  const Color(0xFF14B8A6).withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data harga...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    height: 400,
                    child: _buildErrorState('${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(height: 400, child: _buildEmptyState());
                }

                final marketPrices = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: marketPrices.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _buildPriceCard(item, index);
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

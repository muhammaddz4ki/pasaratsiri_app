import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
//chat_system.dart
// Enhanced Chat System with E-commerce, Analytics, Social, and Financial Features
// nah ini ntar di pisahin zek jadi 4, urg salah malah disatuin

class EnhancedChatSystemScreen extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final Map<String, dynamic> userData;

  const EnhancedChatSystemScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
    required this.userData,
  });

  @override
  State<EnhancedChatSystemScreen> createState() =>
      _EnhancedChatSystemScreenState();
}

class _EnhancedChatSystemScreenState extends State<EnhancedChatSystemScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late TabController _tabController;
  int _currentTabIndex = 0;

  // Financial data
  double _walletBalance = 2500000; // Rp 2.5 jt
  List<Transaction> _transactions = [];

  // Analytics data
  List<MonthlyRevenue> _revenueData = [];

  // Social data
  List<ForumPost> _forumPosts = [];
  List<SocialGroup> _groups = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadChatHistory();
    _loadFinancialData();
    _loadAnalyticsData();
    _loadSocialData();
  }

  void _loadChatHistory() {
    setState(() {
      _messages.addAll([
        ChatMessage(
          id: '1',
          senderId: widget.sellerId,
          senderName: widget.sellerName,
          message: 'Selamat siang, ada yang bisa saya bantu?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isFromCurrentUser: false,
        ),
        ChatMessage(
          id: '2',
          senderId: 'current_user',
          senderName: 'Saya',
          message:
              'Siang pak, mau tanya stock minyak vetiver grade A berapa kg?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isFromCurrentUser: true,
        ),
      ]);
    });
  }

  void _loadFinancialData() {
    setState(() {
      _transactions = [
        Transaction(
          'TXN001',
          'Penjualan Minyak Vetiver',
          1200000,
          DateTime.now().subtract(Duration(days: 1)),
          TransactionType.income,
        ),
        Transaction(
          'TXN002',
          'Pembelian Pupuk',
          -350000,
          DateTime.now().subtract(Duration(days: 2)),
          TransactionType.expense,
        ),
        Transaction(
          'TXN003',
          'Subsidi Pemerintah',
          500000,
          DateTime.now().subtract(Duration(days: 3)),
          TransactionType.income,
        ),
      ];
    });
  }

  void _loadAnalyticsData() {
    setState(() {
      _revenueData = [
        MonthlyRevenue('Jan', 15000000),
        MonthlyRevenue('Feb', 18000000),
        MonthlyRevenue('Mar', 22000000),
        MonthlyRevenue('Apr', 19000000),
        MonthlyRevenue('May', 25000000),
        MonthlyRevenue('Jun', 28000000),
      ];
    });
  }

  void _loadSocialData() {
    setState(() {
      _forumPosts = [
        ForumPost(
          '1',
          'Tips Penyulingan Efektif',
          'Budi Santoso',
          'Sharing pengalaman penyulingan...',
          15,
          DateTime.now().subtract(Duration(hours: 2)),
        ),
        ForumPost(
          '2',
          'Harga Vetiver Naik?',
          'Sari Dewi',
          'Menurut teman-teman bagaimana...',
          8,
          DateTime.now().subtract(Duration(hours: 5)),
        ),
      ];

      _groups = [
        SocialGroup(
          '1',
          'Petani Vetiver Jawa Barat',
          'Grup khusus petani vetiver di Jabar',
          150,
          true,
        ),
        SocialGroup(
          '2',
          'Komunitas Atsiri Indonesia',
          'Komunitas nasional tanaman atsiri',
          2500,
          false,
        ),
        SocialGroup(
          '3',
          'Pemasaran Online Produk Atsiri',
          'Tips dan trik pemasaran',
          850,
          true,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildMarketplaceTab(),
          _buildAnalyticsTab(),
          _buildSocialTab(),
          _buildFinancialTab(),
        ],
      ),
      bottomNavigationBar: _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    List<String> titles = [
      'Chat',
      'Marketplace',
      'Analytics',
      'Social',
      'Financial',
    ];

    return AppBar(
      backgroundColor: Colors.green.shade700,
      foregroundColor: Colors.white,
      title: Text(titles[_currentTabIndex]),
      actions: [
        if (_currentTabIndex == 0) ...[
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startVideoCall(),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startVoiceCall(),
          ),
        ],
        if (_currentTabIndex == 4) ...[
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddMoneyDialog(),
          ),
        ],
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'settings', child: Text('Pengaturan')),
            const PopupMenuItem(value: 'help', child: Text('Bantuan')),
            const PopupMenuItem(value: 'report', child: Text('Laporkan')),
          ],
          onSelected: (value) => _handleMenuAction(value),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable:
            false, // Fixed tabs (replaces the non-existent 'type' parameter)
        labelColor: Colors.green.shade700,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.green.shade700,
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(icon: Icon(Icons.chat), text: 'Chat'),
          Tab(icon: Icon(Icons.shopping_cart), text: 'Market'),
          Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          Tab(icon: Icon(Icons.people), text: 'Social'),
          Tab(icon: Icon(Icons.account_balance_wallet), text: 'Finance'),
        ],
      ),
    );
  }

  // TAB 1: ENHANCED CHAT WITH E-COMMERCE
  Widget _buildChatTab() {
    return Column(
      children: [
        // Seller Info Card with Rating
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.green.shade200,
                child: Text(widget.sellerName[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sellerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '4.8 (127 ulasan)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Online • Membalas dalam 15 menit',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showTransactionDialog(),
                icon: const Icon(Icons.shopping_bag, size: 16),
                label: const Text('Beli', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Chat Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) =>
                _buildMessageBubble(_messages[index]),
          ),
        ),

        // E-commerce Quick Actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _eCommerceActionChip(
                  'Nego Harga',
                  Icons.handshake,
                  Colors.orange,
                ),
                _eCommerceActionChip('Cek Stok', Icons.inventory, Colors.blue),
                _eCommerceActionChip(
                  'Escrow Pay',
                  Icons.security,
                  Colors.green,
                ),
                _eCommerceActionChip(
                  'Minta Review',
                  Icons.star_rate,
                  Colors.purple,
                ),
                _eCommerceActionChip(
                  'Komplain',
                  Icons.report_problem,
                  Colors.red,
                ),
              ],
            ),
          ),
        ),

        // Message Input
        _buildMessageInput(),
      ],
    );
  }

  Widget _eCommerceActionChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 12, color: color)),
        onPressed: () => _handleECommerceAction(label),
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }

  // TAB 2: MARKETPLACE
  Widget _buildMarketplaceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Cari produk atsiri...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 20),

          // Categories
          Text(
            'Kategori Produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _categoryCard('Minyak Atsiri', Icons.water_drop, Colors.green),
                _categoryCard('Bibit Tanaman', Icons.eco, Colors.brown),
                _categoryCard('Peralatan', Icons.build, Colors.orange),
                _categoryCard('Pupuk & Obat', Icons.healing, Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Featured Products
          Text(
            'Produk Unggulan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: [
              _productCard(
                'Minyak Vetiver Grade A',
                'Rp 850.000/L',
                '4.9',
                'assets/vetiver.jpg',
              ),
              _productCard(
                'Minyak Serai Wangi',
                'Rp 650.000/L',
                '4.7',
                'assets/serai.jpg',
              ),
              _productCard(
                'Minyak Nilam Premium',
                'Rp 1.200.000/L',
                '4.8',
                'assets/nilam.jpg',
              ),
              _productCard(
                'Bibit Vetiver Unggul',
                'Rp 15.000/batang',
                '4.6',
                'assets/bibit.jpg',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(
    String name,
    String price,
    String rating,
    String imagePath,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Icon(Icons.image, size: 40, color: Colors.grey.shade400),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(rating, style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: ANALYTICS DASHBOARD
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _analyticsCard(
                  'Pendapatan Bulan Ini',
                  'Rp 28.5M',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _analyticsCard(
                  'Total Transaksi',
                  '156',
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _analyticsCard(
                  'Rata-rata Harga',
                  'Rp 875K/L',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _analyticsCard(
                  'Produk Terjual',
                  '45 L',
                  Icons.inventory_2,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Revenue Chart
          Text(
            'Grafik Pendapatan 6 Bulan Terakhir',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30000000,
                barGroups: _revenueData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.amount.toDouble(),
                        color: Colors.green.shade600,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _revenueData[value.toInt()].month,
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Export Options
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportToPDF(),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportToExcel(),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _analyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: SOCIAL FEATURES
  Widget _buildSocialTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.green.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.green.shade700,
            tabs: const [
              Tab(text: 'Forum'),
              Tab(text: 'Groups'),
              Tab(text: 'Events'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildForumTab(),
                _buildGroupsTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForumTab() {
    return Column(
      children: [
        // Create Post Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showCreatePostDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Buat Post Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Forum Posts
        Expanded(
          child: ListView.builder(
            itemCount: _forumPosts.length,
            itemBuilder: (context, index) =>
                _buildForumPost(_forumPosts[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildForumPost(ForumPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.shade200,
                  child: Text(post.authorName[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatTime(post.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Laporkan'),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('Blokir User'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(post.content, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _likePost(post.id),
                  icon: const Icon(Icons.thumb_up, size: 16),
                  label: Text('${post.likes}'),
                ),
                TextButton.icon(
                  onPressed: () => _showCommentsDialog(post),
                  icon: const Icon(Icons.comment, size: 16),
                  label: const Text('Komentar'),
                ),
                TextButton.icon(
                  onPressed: () => _sharePost(post),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Bagikan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Column(
      children: [
        // Create Group Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(),
            icon: const Icon(Icons.group_add),
            label: const Text('Buat Grup Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        // Groups List
        Expanded(
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) => _buildGroupItem(_groups[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupItem(SocialGroup group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade200,
          child: Icon(Icons.group, color: Colors.blue.shade700),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.description),
            const SizedBox(height: 4),
            Text(
              '${group.memberCount} anggota',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _toggleGroupMembership(group.id),
          child: Text(group.isJoined ? 'Keluar' : 'Gabung'),
          style: ElevatedButton.styleFrom(
            backgroundColor: group.isJoined
                ? Colors.red.shade400
                : Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(60, 32),
          ),
        ),
        onTap: () => _openGroupChat(group),
      ),
    );
  }

  Widget _buildEventsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEventCard(
          'Workshop Penyulingan Modern',
          'Belajar teknik penyulingan terbaru dengan teknologi canggih',
          DateTime.now().add(const Duration(days: 7)),
          'Bandung, Jawa Barat',
          'Rp 150.000',
          false,
        ),
        _buildEventCard(
          'Pameran Produk Atsiri Nusantara',
          'Pameran dan expo produk-produk atsiri dari seluruh Indonesia',
          DateTime.now().add(const Duration(days: 14)),
          'Jakarta Convention Center',
          'Gratis',
          true,
        ),
        _buildEventCard(
          'Pelatihan Sertifikasi Organik',
          'Pelatihan mendapatkan sertifikat organik untuk produk atsiri',
          DateTime.now().add(const Duration(days: 21)),
          'Yogyakarta',
          'Rp 200.000',
          false,
        ),
      ],
    );
  }

  Widget _buildEventCard(
    String title,
    String description,
    DateTime date,
    String location,
    String price,
    bool isRegistered,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(location, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(price, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _registerForEvent(title),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRegistered
                      ? Colors.grey
                      : Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isRegistered ? 'Sudah Terdaftar' : 'Daftar Sekarang',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 5: FINANCIAL SERVICES
  Widget _buildFinancialTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.green.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.green.shade700,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Wallet'),
              Tab(text: 'Kredit'),
              Tab(text: 'Asuransi'),
              Tab(text: 'Investasi'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWalletTab(),
                _buildCreditTab(),
                _buildInsuranceTab(),
                _buildInvestmentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet Balance Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade800],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo Digital Wallet',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${_formatCurrency(_walletBalance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showTopUpDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Top Up'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showWithdrawDialog(),
                        icon: const Icon(Icons.remove, size: 18),
                        label: const Text('Tarik'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Aksi Cepat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _walletQuickAction(
                'Transfer',
                Icons.send,
                () => _showTransferDialog(),
              ),
              _walletQuickAction(
                'Bayar',
                Icons.payment,
                () => _showPaymentDialog(),
              ),
              _walletQuickAction(
                'Scan QR',
                Icons.qr_code_scanner,
                () => _scanQR(),
              ),
              _walletQuickAction(
                'Riwayat',
                Icons.history,
                () => _showTransactionHistory(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaksi Terakhir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showTransactionHistory(),
                child: Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.take(5).length,
            itemBuilder: (context, index) =>
                _buildTransactionItem(_transactions[index]),
          ),
        ],
      ),
    );
  }

  Widget _walletQuickAction(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Icon(icon, color: Colors.green.shade600, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(_formatDate(transaction.date)),
        trailing: Text(
          '${isIncome ? '+' : ''}Rp ${_formatCurrency(transaction.amount.abs())}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildCreditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Skor Kredit Anda',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '750',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'BAIK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Limit tersedia: Rp 15.000.000',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Available Loans
          Text(
            'Pinjaman Tersedia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _loanCard(
            'Kredit Modal Usaha',
            'Untuk modal pembelian bibit dan peralatan',
            'Bunga 12% per tahun',
            'Maksimal Rp 20.000.000',
            Icons.agriculture,
          ),
          _loanCard(
            'Kredit Musiman',
            'Pinjaman untuk masa tanam dan panen',
            'Bunga 10% per tahun',
            'Maksimal Rp 10.000.000',
            Icons.calendar_month,
          ),
          _loanCard(
            'Kredit Peralatan',
            'Untuk pembelian alat penyulingan',
            'Bunga 15% per tahun',
            'Maksimal Rp 50.000.000',
            Icons.build,
          ),
          const SizedBox(height: 24),

          // Current Loans
          Text(
            'Pinjaman Aktif',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kredit Modal Usaha',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'LANCAR',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Sisa Pinjaman: Rp 8.500.000'),
                  Text('Cicilan per bulan: Rp 750.000'),
                  Text('Jatuh tempo: 15 setiap bulan'),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.4,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '40% terbayar',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanCard(
    String title,
    String description,
    String interest,
    String maxAmount,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.blue.shade600),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(interest, style: const TextStyle(fontSize: 12)),
                ),
                Expanded(
                  child: Text(maxAmount, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _applyForLoan(title),
                child: const Text('Ajukan Pinjaman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Insurance
          Text(
            'Asuransi Aktif',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.security,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asuransi Tanaman Atsiri Premium',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Berlaku hingga: 15 Desember 2025',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'AKTIF',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Premi Bulanan'),
                            Text(
                              'Rp 125.000',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nilai Pertanggungan'),
                            Text(
                              'Rp 50.000.000',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showClaimDialog(),
                          child: const Text('Klaim'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _payInsurancePremium(),
                          child: const Text('Bayar Premi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Available Insurance
          Text(
            'Asuransi Tersedia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _insuranceCard(
            'Asuransi Cuaca Ekstrem',
            'Perlindungan dari kerugian akibat cuaca buruk',
            'Mulai Rp 75.000/bulan',
            Icons.cloud,
            Colors.blue,
          ),
          _insuranceCard(
            'Asuransi Hama & Penyakit',
            'Perlindungan dari serangan hama dan penyakit tanaman',
            'Mulai Rp 100.000/bulan',
            Icons.bug_report,
            Colors.red,
          ),
          _insuranceCard(
            'Asuransi Peralatan',
            'Perlindungan untuk alat penyulingan dan peralatan pertanian',
            'Mulai Rp 150.000/bulan',
            Icons.build,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _insuranceCard(
    String title,
    String description,
    String premium,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        premium,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _buyInsurance(title),
                child: const Text('Beli Asuransi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade600, Colors.purple.shade800],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Portofolio',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rp 12.500.000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5% (Rp 1.375.000)',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Investment Options
          Text(
            'Opsi Investasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _investmentCard(
            'Komoditas Minyak Atsiri',
            'Investasi langsung pada komoditas minyak atsiri',
            'Return: 15-25% per tahun',
            'Risiko: Menengah',
            Icons.water_drop,
            Colors.green,
            'Rp 1.000.000',
          ),
          _investmentCard(
            'Reksadana Agrikultur',
            'Portofolio terdiversifikasi sektor pertanian',
            'Return: 8-15% per tahun',
            'Risiko: Rendah-Menengah',
            Icons.agriculture,
            Colors.blue,
            'Rp 100.000',
          ),
          _investmentCard(
            'P2P Lending Petani',
            'Pendanaan langsung ke petani dengan bunga menarik',
            'Return: 12-20% per tahun',
            'Risiko: Menengah-Tinggi',
            Icons.handshake,
            Colors.orange,
            'Rp 500.000',
          ),
          const SizedBox(height: 24),

          // Current Investments
          Text(
            'Investasi Aktif',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _currentInvestmentItem(
                    'Komoditas Vetiver',
                    'Rp 5.000.000',
                    '+18.5%',
                    Colors.green,
                  ),
                  const Divider(),
                  _currentInvestmentItem(
                    'Reksadana Agri Fund',
                    'Rp 3.000.000',
                    '+12.3%',
                    Colors.blue,
                  ),
                  const Divider(),
                  _currentInvestmentItem(
                    'P2P Funding Serai',
                    'Rp 4.500.000',
                    '+15.7%',
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _investmentCard(
    String title,
    String description,
    String returnRate,
    String risk,
    IconData icon,
    Color color,
    String minInvestment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    returnRate,
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(risk, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Minimum: $minInvestment',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _investIn(title),
                child: const Text('Investasi Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentInvestmentItem(
    String name,
    String amount,
    String growth,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                growth,
                style: TextStyle(color: Colors.green.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Common Widgets
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.shade100,
              child: Text(
                message.senderName[0],
                style: TextStyle(color: Colors.green.shade700, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? Colors.green.shade600
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isFromCurrentUser
                          ? Colors.green.shade100
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isFromCurrentUser) ...[
            const SizedBox(width: 8),
            Icon(Icons.done_all, size: 16, color: Colors.green.shade600),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.green.shade600),
            onPressed: () => _showAttachmentOptions(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.green.shade600,
            onPressed: () => _sendMessage(),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // Action Methods
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'Saya',
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isFromCurrentUser: true,
    );

    setState(() {
      _messages.add(message);
    });

    _messageController.clear();

    // Simulate seller reply
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              senderId: widget.sellerId,
              senderName: widget.sellerName,
              message: 'Baik, saya akan cek informasi tersebut untuk Anda.',
              timestamp: DateTime.now(),
              isFromCurrentUser: false,
            ),
          );
        });
      }
    });
  }

  void _handleECommerceAction(String action) {
    String message = '';
    switch (action) {
      case 'Nego Harga':
        message = 'Bisa nego harga tidak pak? Saya beli dalam jumlah besar.';
        break;
      case 'Cek Stok':
        message = 'Masih ada stok tidak pak? Butuh berapa kg?';
        break;
      case 'Escrow Pay':
        _showEscrowDialog();
        return;
      case 'Minta Review':
        _showReviewDialog();
        return;
      case 'Komplain':
        _showComplainDialog();
        return;
    }
    _messageController.text = message;
    _sendMessage();
  }

  void _showTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaksi Aman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.security, color: Colors.green.shade600),
              title: const Text('Escrow Payment'),
              subtitle: const Text(
                'Pembayaran diamankan hingga barang diterima',
              ),
              onTap: () {
                Navigator.pop(context);
                _showEscrowDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.payment, color: Colors.blue.shade600),
              title: const Text('Bayar Langsung'),
              subtitle: const Text('Transfer langsung ke penjual'),
              onTap: () {
                Navigator.pop(context);
                _showDirectPaymentDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEscrowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escrow Payment System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sistem pembayaran aman dengan jaminan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _escrowStep('1', 'Pembeli transfer ke escrow account'),
            _escrowStep('2', 'Penjual kirim barang sesuai pesanan'),
            _escrowStep('3', 'Pembeli konfirmasi barang diterima'),
            _escrowStep('4', 'Dana ditransfer ke penjual'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% Uang kembali jika barang tidak sesuai',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
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
              _processEscrowPayment();
            },
            child: const Text('Gunakan Escrow'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _escrowStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog() {
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Berikan Rating & Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bagaimana pengalaman Anda?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () => setState(() => rating = index + 1),
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis review Anda...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                _submitReview(rating);
              },
              child: const Text('Kirim Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComplainDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Laporkan Masalah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.orange),
              title: const Text('Barang Tidak Sesuai'),
              onTap: () => _fileComplaint('Barang Tidak Sesuai'),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.red),
              title: const Text('Pengiriman Terlambat'),
              onTap: () => _fileComplaint('Pengiriman Terlambat'),
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.purple),
              title: const Text('Masalah Pembayaran'),
              onTap: () => _fileComplaint('Masalah Pembayaran'),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Lainnya'),
              onTap: () => _fileComplaint('Lainnya'),
            ),
          ],
        ),
      ),
    );
  }

  // Financial Methods
  void _showTopUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Top Up Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Top Up',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Metode Pembayaran:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Transfer Bank'),
              onTap: () => _selectPaymentMethod('Bank Transfer'),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Kartu Kredit/Debit'),
              onTap: () => _selectPaymentMethod('Credit Card'),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QRIS'),
              onTap: () => _selectPaymentMethod('QRIS'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarik Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Penarikan',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText:
                    'Saldo tersedia: Rp ${_formatCurrency(_walletBalance)}',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Rekening Bank',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              _processWithdraw();
            },
            child: const Text('Tarik Saldo'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer ke Pengguna Lain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'ID Pengguna / Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Transfer',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Pesan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              _processTransfer();
            },
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _quickAmountButton('100K', 100000)),
                const SizedBox(width: 8),
                Expanded(child: _quickAmountButton('250K', 250000)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _quickAmountButton('500K', 500000)),
                const SizedBox(width: 8),
                Expanded(child: _quickAmountButton('1M', 1000000)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Lainnya',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  Widget _quickAmountButton(String label, double amount) {
    return ElevatedButton(
      onPressed: () => _selectQuickAmount(amount),
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade100,
        foregroundColor: Colors.green.shade700,
      ),
    );
  }

  // Social Methods
  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Post Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Judul Post',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Isi Post',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
              _createPost();
            },
            child: const Text('Posting'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Grup Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Nama Grup',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi Grup',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Grup Privat'),
              subtitle: const Text('Hanya bisa diakses dengan undangan'),
              value: false,
              onChanged: (bool value) {},
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
              _createGroup();
            },
            child: const Text('Buat Grup'),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(ForumPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Komentar - ${post.title}'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _commentItem(
                      'Andi Pratama',
                      'Terima kasih infonya, sangat membantu!',
                      '2 jam lalu',
                    ),
                    _commentItem(
                      'Sari Wulan',
                      'Apakah ini berlaku untuk semua jenis tanaman atsiri?',
                      '1 jam lalu',
                    ),
                    _commentItem(
                      'Budi Santoso',
                      'Sudah saya coba dan hasilnya bagus',
                      '30 menit lalu',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _postComment(post.id),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _commentItem(String author, String comment, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // Analytics Methods
  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF berhasil! File disimpan di Downloads.'),
      ),
    );
  }

  void _exportToExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export Excel berhasil! File disimpan di Downloads.'),
      ),
    );
  }

  // Implementation Methods
  void _startVideoCall() =>
      print('Starting video call with ${widget.sellerName}');
  void _startVoiceCall() =>
      print('Starting voice call with ${widget.sellerName}');
  void _handleMenuAction(String action) => print('Menu action: $action');
  void _showAttachmentOptions() => print('Show attachment options');
  void _processEscrowPayment() => print('Processing escrow payment');
  void _showDirectPaymentDialog() => print('Show direct payment dialog');
  void _submitReview(int rating) => print('Submit review with $rating stars');
  void _fileComplaint(String type) => print('File complaint: $type');
  void _selectPaymentMethod(String method) =>
      print('Selected payment method: $method');
  void _processWithdraw() => print('Processing withdraw');
  void _processTransfer() => print('Processing transfer');
  void _selectQuickAmount(double amount) =>
      print('Selected quick amount: $amount');
  void _likePost(String postId) => print('Liked post: $postId');
  void _sharePost(ForumPost post) => print('Share post: ${post.title}');
  void _createPost() => print('Creating new post');
  void _createGroup() => print('Creating new group');
  void _toggleGroupMembership(String groupId) =>
      print('Toggle group membership: $groupId');
  void _openGroupChat(SocialGroup group) =>
      print('Opening group chat: ${group.name}');
  void _postComment(String postId) => print('Posting comment to: $postId');
  void _registerForEvent(String eventTitle) =>
      print('Registering for event: $eventTitle');
  void _applyForLoan(String loanType) => print('Applying for loan: $loanType');
  void _showClaimDialog() => print('Show insurance claim dialog');
  void _payInsurancePremium() => print('Pay insurance premium');
  void _buyInsurance(String insuranceType) =>
      print('Buy insurance: $insuranceType');
  void _investIn(String investmentType) => print('Invest in: $investmentType');
  void _showPaymentDialog() => print('Show payment dialog');
  void _scanQR() => print('Scanning QR code');
  void _showTransactionHistory() => print('Show transaction history');

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

// Data Models
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromCurrentUser;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromCurrentUser,
  });
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction(this.id, this.description, this.amount, this.date, this.type);
}

enum TransactionType { income, expense }

class MonthlyRevenue {
  final String month;
  final double amount;

  MonthlyRevenue(this.month, this.amount);
}

class ForumPost {
  final String id;
  final String title;
  final String authorName;
  final String content;
  final int likes;
  final DateTime timestamp;

  ForumPost(
    this.id,
    this.title,
    this.authorName,
    this.content,
    this.likes,
    this.timestamp,
  );
}

class SocialGroup {
  final String id;
  final String name;
  final String description;
  final int memberCount;
  final bool isJoined;

  SocialGroup(
    this.id,
    this.name,
    this.description,
    this.memberCount,
    this.isJoined,
  );
}

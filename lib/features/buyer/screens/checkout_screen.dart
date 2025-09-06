// lib/features/buyer/screens/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pasaratsiri_app/features/auth/services/auth_service.dart';
import 'package:pasaratsiri_app/features/buyer/models/voucher_model.dart';
import 'package:pasaratsiri_app/features/buyer/screens/buyer_dashboard.dart';
import 'package:pasaratsiri_app/features/buyer/services/voucher_service.dart';
import '../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;
  const CheckoutScreen({super.key, required this.totalPrice});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();
  final VoucherService _voucherService = VoucherService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // --- State & Styling ---
  bool _isLoading = false;
  String _selectedPaymentMethod = 'Bank Transfer';
  List<Voucher> _availableVouchers = [];
  Voucher? _selectedVoucher;
  double _subtotal = 0;
  double _discountAmount = 0;
  double _finalPrice = 0;

  // Warna konsisten dari dashboard
  static const Color primaryColor = Color(0xFF10B981);
  static const Color darkColor = Color(0xFF047857);
  static const Color ultraLightColor = Color(0xFFECFDF5);

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'name': 'GoPay', 'icon': Icons.payment},
    {'name': 'OVO', 'icon': Icons.lens_blur},
    {'name': 'DANA', 'icon': Icons.account_balance_wallet},
  ];

  @override
  void initState() {
    super.initState();
    _subtotal = widget.totalPrice;
    _finalPrice = widget.totalPrice;
    _loadVouchers();
  }

  void _loadVouchers() async {
    _availableVouchers = await _voucherService.getAvailableVouchers();
    if (mounted) {
      setState(() {});
    }
  }

  void _applyVoucher(Voucher voucher) {
    if (_subtotal < voucher.minSpend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimal belanja untuk voucher ini adalah ${_currencyFormat.format(voucher.minSpend)}',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedVoucher = voucher;
      _discountAmount = (_subtotal * voucher.discountValue) / 100;
      _finalPrice = _subtotal - _discountAmount;
    });
    Navigator.pop(context); // Tutup modal pilih voucher
  }

  void _removeVoucher() {
    setState(() {
      _selectedVoucher = null;
      _discountAmount = 0;
      _finalPrice = _subtotal;
    });
  }

  void _processOrder() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _orderService.createOrder(
        address: _addressController.text,
        totalPrice: _finalPrice,
        paymentMethod: _selectedPaymentMethod,
        appliedVoucherId: _selectedVoucher?.id,
        discountAmount: _discountAmount,
        voucherTitle: _selectedVoucher?.title,
      );

      final Map<String, dynamic>? userData = await AuthService()
          .getCurrentUserData();
      setState(() => _isLoading = false);

      if (mounted) {
        if (result == null && userData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil dibuat!'),
              backgroundColor: primaryColor,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  PembeliDashboard(userData: userData, initialPageIndex: 1),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: $result'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkColor,
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSectionTitle(
                    'Alamat Pengiriman',
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildAddressField(),
                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Gunakan Voucher',
                    Icons.local_offer_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildVoucherSection(),
                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'Metode Pembayaran',
                    Icons.wallet_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomBar(), // Bottom bar untuk total dan tombol order
        ],
      ),
    );
  }

  // Widget baru untuk judul setiap seksi
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: darkColor, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Widget baru untuk kartu info
  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Masukkan alamat lengkap Anda...',
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Alamat tidak boleh kosong.';
        }
        return null;
      },
    );
  }

  Widget _buildVoucherSection() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showVoucherSelection(context),
        borderRadius: BorderRadius.circular(12),
        child: _buildInfoCard(
          child: Row(
            children: [
              Icon(
                _selectedVoucher != null
                    ? Icons.check_circle
                    : Icons.local_offer,
                color: _selectedVoucher != null ? primaryColor : Colors.orange,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _selectedVoucher?.title ?? 'Pilih atau masukkan kode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _selectedVoucher != null
                        ? darkColor
                        : Colors.black87,
                  ),
                ),
              ),
              if (_selectedVoucher != null)
                GestureDetector(
                  onTap: _removeVoucher,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return _buildInfoCard(
      child: Column(
        children: _paymentMethods.map((method) {
          bool isSelected = _selectedPaymentMethod == method['name'];
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedPaymentMethod = method['name']),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? ultraLightColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method['icon'],
                    color: isSelected ? darkColor : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? darkColor : Colors.black87,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: primaryColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ringkasan Pesanan di dalam bottom bar
          _buildOrderSummary(),
          const SizedBox(height: 16),
          // Tombol Order
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _processOrder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'Buat Pesanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        _summaryRow('Subtotal', _currencyFormat.format(_subtotal)),
        if (_selectedVoucher != null) ...[
          const SizedBox(height: 8),
          _summaryRow(
            'Diskon (${_selectedVoucher!.title})',
            '- ${_currencyFormat.format(_discountAmount)}',
            isDiscount: true,
          ),
        ],
        const Divider(height: 20, thickness: 1),
        _summaryRow(
          'Total Pembayaran',
          _currencyFormat.format(_finalPrice),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _summaryRow(
    String title,
    String amount, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.black54,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: isDiscount
                ? Colors.red.shade600
                : (isTotal ? darkColor : Colors.black87),
          ),
        ),
      ],
    );
  }

  void _showVoucherSelection(BuildContext context) {
    // Implementasi modal bottom sheet untuk voucher tidak berubah,
    // jadi Anda bisa menggunakan fungsi yang sudah ada.
    // Pastikan UI di dalamnya juga konsisten jika diperlukan.
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Voucher",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_availableVouchers.isEmpty)
                const Center(
                  heightFactor: 5,
                  child: Text("Anda tidak memiliki voucher."),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _availableVouchers.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final voucher = _availableVouchers[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.local_offer,
                          color: primaryColor,
                        ),
                        title: Text(voucher.title),
                        subtitle: Text(
                          "Diskon ${voucher.discountValue}%, Min. Belanja ${_currencyFormat.format(voucher.minSpend)}",
                        ),
                        onTap: () => _applyVoucher(voucher),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

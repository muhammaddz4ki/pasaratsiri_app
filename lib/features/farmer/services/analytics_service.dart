import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // <-- TAMBAHKAN IMPORT INI

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, double>> getMonthlyIncomeData() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    QuerySnapshot orderSnapshot = await _firestore
        .collection('orders')
        .where('sellerIds', arrayContains: user.uid)
        .where('status', isEqualTo: 'Selesai')
        .where('completedAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('completedAt', isLessThanOrEqualTo: endOfMonth)
        .get();

    Map<String, double> weeklyIncome = {
      'Minggu 1': 0.0,
      'Minggu 2': 0.0,
      'Minggu 3': 0.0,
      'Minggu 4': 0.0,
    };

    if (endOfMonth.day > 28) {
      weeklyIncome['Minggu 5'] = 0.0;
    }

    for (var orderDoc in orderSnapshot.docs) {
      final orderData = orderDoc.data() as Map<String, dynamic>;
      DateTime completedDate = (orderData['completedAt'] as Timestamp).toDate();

      double farmerIncomeFromThisOrder = 0.0;
      List<dynamic> items = orderData['items'];
      for (var item in items) {
        if (item['sellerId'] == user.uid) {
          farmerIncomeFromThisOrder += (item['price'] * item['quantity'])
              .toDouble();
        }
      }

      int weekOfMonth = ((completedDate.day - 1) / 7).floor() + 1;
      if (weekOfMonth >= 1 && weekOfMonth <= 5) {
        weeklyIncome['Minggu $weekOfMonth'] =
            (weeklyIncome['Minggu $weekOfMonth'] ?? 0.0) +
            farmerIncomeFromThisOrder;
      }
    }

    weeklyIncome.removeWhere((key, value) => value == 0.0);
    return weeklyIncome;
  }

  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    QuerySnapshot orderSnapshot = await _firestore
        .collection('orders')
        .where('sellerIds', arrayContains: user.uid)
        .where('status', isEqualTo: 'Selesai')
        .where('completedAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('completedAt', isLessThanOrEqualTo: endOfMonth)
        .get();

    if (orderSnapshot.docs.isEmpty) {
      return {'totalOrders': 0, 'topProduct': '-', 'averageOrderValue': 0.0};
    }

    int totalOrders = orderSnapshot.docs.length;
    double totalIncome = 0;
    Map<String, int> productQuantities = {};

    for (var orderDoc in orderSnapshot.docs) {
      final orderData = orderDoc.data() as Map<String, dynamic>;
      List<dynamic> items = orderData['items'];
      for (var item in items) {
        if (item['sellerId'] == user.uid) {
          totalIncome += (item['price'] * item['quantity']).toDouble();

          String productName = item['productName'];
          int quantity = item['quantity'];
          productQuantities[productName] =
              (productQuantities[productName] ?? 0) + quantity;
        }
      }
    }

    String topProduct = '-';
    if (productQuantities.isNotEmpty) {
      topProduct = productQuantities.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    double averageOrderValue = totalIncome / totalOrders;

    return {
      'totalOrders': totalOrders,
      'topProduct': topProduct,
      'averageOrderValue': averageOrderValue,
    };
  }

  Future<List<FlSpot>> getPriceTrendData(String commodityId) async {
    DateTime threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

    QuerySnapshot snapshot = await _firestore
        .collection('market_prices')
        .doc(commodityId)
        .collection('price_history')
        .where('date', isGreaterThanOrEqualTo: threeMonthsAgo)
        .orderBy('date', descending: false)
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    return snapshot.docs.map((doc) {
      Timestamp timestamp = doc['date'] as Timestamp;
      double price = (doc['price'] as num).toDouble();

      return FlSpot(timestamp.millisecondsSinceEpoch.toDouble(), price);
    }).toList();
  }
}

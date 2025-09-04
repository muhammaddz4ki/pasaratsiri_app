// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
// --- 1. UBAH IMPORT INI ---
// Import model Training dari government, bukan farmer
import 'package:pasaratsiri_app/features/government/models/training_model.dart';
import 'package:pasaratsiri_app/features/farmer/screens/certification_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/market_price_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/product_list_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/subsidy_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/training_detail_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/add_certification_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/add_subsidy_screen.dart';
import 'features/shared/widgets/auth_wrapper.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/shared/screens/home_screen.dart';
import 'features/auth/screens/role_selection_screen.dart';
import 'features/auth/screens/multi_step_register_screen.dart';
import 'features/shared/screens/splash_screen.dart';
import 'features/buyer/screens/catalog_screen.dart';
import 'features/farmer/screens/add_product_screen.dart';
import 'features/buyer/screens/cart_screen.dart';
import 'features/buyer/screens/checkout_screen.dart';
import 'features/buyer/screens/order_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasar Atsiri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register-role-selection': (context) => const RoleSelectionScreen(),
        '/multi-step-register': (context) => const MultiStepRegisterScreen(),
        '/catalog': (context) => const CatalogScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(totalPrice: 0),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/product-list': (context) => const ProductListScreen(),
        '/market-price': (context) => const MarketPriceScreen(),
        '/certification': (context) => const CertificationScreen(),
        '/subsidy': (context) => const SubsidyScreen(),
        '/add-certification': (context) => const AddCertificationScreen(),
        '/add-subsidy': (context) => const AddSubsidyScreen(),
      },
      // --- 2. UBAH LOGIKA INI ---
      // Tambahkan onGenerateRoute untuk halaman yang butuh argumen
      onGenerateRoute: (settings) {
        if (settings.name == '/training-detail') {
          // Ganti TrainingModule menjadi Training
          final Training training = settings.arguments as Training;
          return MaterialPageRoute(
            builder: (context) {
              // Ganti module: module menjadi training: training
              return TrainingDetailScreen(training: training);
            },
          );
        }
        return null; // Penting untuk rute lain yang tidak terdefinisi
      },
    );
  }
}

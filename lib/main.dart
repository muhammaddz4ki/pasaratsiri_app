import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
        '/add-product': (context) => const AddProductScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(totalPrice: 0),
        '/order-history': (context) => const OrderHistoryScreen(),
      },
    );
  }
}

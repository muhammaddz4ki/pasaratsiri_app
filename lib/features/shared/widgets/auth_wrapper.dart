import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pasaratsiri_app/features/auth/screens/login_screen.dart';
import 'package:pasaratsiri_app/features/shared/screens/home_screen.dart';
import 'package:pasaratsiri_app/features/farmer/screens/farmer_dashboard.dart';
import 'package:pasaratsiri_app/features/buyer/screens/buyer_dashboard.dart';
import 'package:pasaratsiri_app/features/distiller/screens/distiller_dashboard.dart';
import 'package:pasaratsiri_app/features/government/screens/government_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.data();
      } else {
        debugPrint(
          "Dokumen user dengan UID $uid tidak ditemukan di Firestore.",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Error saat _getUserData: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = snapshot.data!;
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(user.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!userSnapshot.hasData || userSnapshot.data == null) {
              return const HomeScreen();
            }

            final userData = userSnapshot.data!;
            final role = userData['role'];
            final createdAt = userData['createdAt'] as Timestamp?;

            // Cek apakah akun baru dibuat dalam 10 detik terakhir
            final bool isNewlyRegistered =
                createdAt != null &&
                (Timestamp.now().seconds - createdAt.seconds < 10);

            Widget dashboardPage;
            switch (role) {
              case 'petani':
                dashboardPage = FarmerDashboard(userData: userData);
                break;
              case 'pembeli':
                dashboardPage = PembeliDashboard(userData: userData);
                break;
              case 'penyulingan':
                dashboardPage = UnitPenyulinganDashboard(userData: userData);
                break;
              case 'pemerintah':
                dashboardPage = PemerintahDashboard(userData: userData);
                break;
              default:
                dashboardPage = const HomeScreen();
            }

            // Jika ini adalah registrasi baru, bungkus dashboard dengan Notifier
            if (isNewlyRegistered) {
              return RegistrationSuccessNotifier(child: dashboardPage);
            } else {
              return dashboardPage;
            }
          },
        );
      },
    );
  }
}

// WIDGET BARU UNTUK MENAMPILKAN NOTIFIKASI
class RegistrationSuccessNotifier extends StatefulWidget {
  final Widget child;
  const RegistrationSuccessNotifier({super.key, required this.child});

  @override
  State<RegistrationSuccessNotifier> createState() =>
      _RegistrationSuccessNotifierState();
}

class _RegistrationSuccessNotifierState
    extends State<RegistrationSuccessNotifier> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

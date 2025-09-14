import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cover_page.dart';
import 'observer_form_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Menunggu koneksi Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Jika user sudah login, langsung ke observer form
        if (snapshot.hasData && snapshot.data != null) {
          return const ObserverFormPage();
        }
        
        // Jika user belum login, tampilkan cover page
        return const CoverPage();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CoverPage extends StatelessWidget {
  const CoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo di atas
            Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Image.asset(
                'assets/images/vossa4tefa.png',
                height: 150,
              ),
            ),

            const SizedBox(height: 50),

            // Lottie animation
            SizedBox(
              height: 180,
              child: Lottie.asset('assets/animations/team_work.json'),
            ),

            const SizedBox(height: 30),

            const Text(
              'Aplikasi Penilaian Soft Skills',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'pada Pembelajaran Teaching Factory (TeFa) di SMK',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                // Langsung ke halaman identitas observer tanpa login
                Navigator.pushNamed(context, '/observerForm');
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Mulai',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

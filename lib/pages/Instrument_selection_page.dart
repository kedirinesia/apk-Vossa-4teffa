import 'package:flutter/material.dart';
import '../models/observer_data.dart';

class InstrumentSelectionPage extends StatelessWidget {
  final ObserverData observerData;

  const InstrumentSelectionPage({
    super.key,
    required this.observerData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // soft blue
      appBar: AppBar(
        title: const Text('Pilih Jenis Instrumen'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Data Observer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Nama Observer : ${observerData.observerName}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Sekolah        : ${observerData.schoolName}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Mitra          : ${observerData.mitraName}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Peran          : ${observerData.role}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.house, color: Colors.white),
                    label: const Text(
                      'Observasi Berbasis Produksi',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 103, 87, 109),
                      minimumSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/studentForm',
                        arguments: {
                          'observerData': observerData,
                          'instrumentType': 'Produksi',
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.precision_manufacturing, color: Colors.white),
                    label: const Text(
                      'Observasi Berbasis Layanan/Jasa',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 209, 119, 9),
                      minimumSize: const Size(280, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/studentForm',
                        arguments: {
                          'observerData': observerData,
                          'instrumentType': 'Layanan',
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Gambar kecil di posisi bottom center
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/vossa4tefa.png',
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

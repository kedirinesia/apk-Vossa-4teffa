import 'package:flutter/material.dart';
import '../models/observer_data.dart';
import 'instrument_selection_page.dart';

class ObserverFormPage extends StatefulWidget {
  const ObserverFormPage({super.key});

  @override
  State<ObserverFormPage> createState() => _ObserverFormPageState();
}

class _ObserverFormPageState extends State<ObserverFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _observerNameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _mitraNameController = TextEditingController();
  String _role = 'guru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // soft blue background
      appBar: AppBar(
        title: const Text('Identitas Observer'),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Judul Data Observer, di atas dan center horizontal
              const Text(
                "Data Observer",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 12),

              // Form input - posisi start (rata kiri)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
                          children: [
                            // Nama Observer
                            TextFormField(
                              controller: _observerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Observer',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),

                            // Nama Sekolah
                            TextFormField(
                              controller: _schoolNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Sekolah',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.school),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),

                            // Mitra Industri
                            TextFormField(
                              controller: _mitraNameController,
                              decoration: const InputDecoration(
                                labelText: 'Mitra Industri',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.handshake),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 16),

                            // Peran
                            DropdownButtonFormField<String>(
                              initialValue: _role,
                              decoration: const InputDecoration(
                                labelText: 'Peran',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'guru', child: Text('Guru')),
                                DropdownMenuItem(
                                    value: 'mitra', child: Text('Perwakilan Mitra DUDI')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _role = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 32),

                            Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  textStyle: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final observerData = ObserverData(
                                      observerName: _observerNameController.text.trim(),
                                      schoolName: _schoolNameController.text.trim(),
                                      mitraName: _mitraNameController.text.trim(),
                                      role: _role,
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            InstrumentSelectionPage(observerData: observerData),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Lanjut ke Pilih Instrumen'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Gambar kecil di bawah halaman
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Image.asset(
                  'assets/images/vossa4tefa.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

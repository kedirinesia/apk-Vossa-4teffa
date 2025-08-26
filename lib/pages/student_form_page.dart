import 'package:flutter/material.dart';
import '../models/student.dart';
import 'assessment_page.dart';
import '../models/observer_data.dart';

class StudentFormPage extends StatefulWidget {
  final ObserverData observerData;
  final String instrumentType;

  const StudentFormPage({
    super.key,
    required this.observerData,
    required this.instrumentType,
  });

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _studentControllers = [TextEditingController()];
  String selectedKelas = 'X';
  String selectedProgram = 'Teknik Komputer dan Jaringan';

  final List<String> programKeahlianList = [
    'Teknik Kendaraan Ringan Otomotif',
    'Teknik Otomotif',
    'Teknik Mesin',
    'Teknik Pemesinan',
    'Teknik Instalasi Tenaga Listrik',
    'Teknik Ketenagalistrikan',
    'Sistem Informatika Jaringan dan Aplikasi',
    'Teknik Komputer dan Jaringan',
    'Teknik Audio dan Video',
    'Teknik Konstruksi dan Properti',
    'Desain Pemodelan dan Informasi Bangunan',
    'Konstruksi Gedung, Sanitasi dan Perawatan',
    'Teknik Konstruksi',
    'Teknik Geomatika',
    'Teknik Geologi Pertambangan',
    'Teknik Kimia',
    'Rekayasa Perangkat Lunak',
    'Tata Boga',
    'Akuntansi dan Keuangan',
  ];

  void _addStudentField() {
    if (_studentControllers.length < 35) {
      setState(() {
        _studentControllers.add(TextEditingController());
      });
    }
  }

  void _removeStudentField(int index) {
    if (_studentControllers.length > 1) {
      setState(() {
        _studentControllers.removeAt(index);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final students = _studentControllers
          .where((controller) => controller.text.trim().isNotEmpty)
          .map((controller) => Student(name: controller.text.trim()))
          .toList();

      if (students.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Minimal 1 siswa harus diisi')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentPage(
            students: students.map((s) => s.name).toList(),
            instrumentType: widget.instrumentType,
            classLevel: selectedKelas,
            programKeahlian: selectedProgram,
            observerData: widget.observerData,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _studentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Data Siswa'),
        backgroundColor: Colors.blue.shade700,
      ),
      backgroundColor: const Color(0xFFE3F2FD),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Pilih Kelas:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: selectedKelas,
                    onChanged: (value) => setState(() => selectedKelas = value!),
                    items: ['X', 'XI', 'XII']
                        .map((kelas) => DropdownMenuItem(value: kelas, child: Text(kelas)))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Pilih Program Keahlian:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: selectedProgram,
                    onChanged: (value) => setState(() => selectedProgram = value!),
                    items: programKeahlianList
                        .map((prog) => DropdownMenuItem(value: prog, child: Text(prog)))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Daftar Siswa (maks. 35):', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._studentControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(labelText: 'Nama Siswa ${index + 1}'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Harus diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeStudentField(index),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _studentControllers.length < 35 ? _addStudentField : null,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Siswa'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Lanjut ke Penilaian'),
                    ),
                  ),
                  const SizedBox(height: 80), // jarak bawah agar gambar tidak menindih konten
                ],
              ),
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

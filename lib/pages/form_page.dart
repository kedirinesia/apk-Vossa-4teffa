import 'package:flutter/material.dart';
import '../models/student.dart';

class FormPage extends StatefulWidget {
  final Student student;

  const FormPage({super.key, required this.student});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final Map<String, double> _scores = {
    'Komunikasi': 0,
    'Kerja Sama': 0,
    'Tanggung Jawab': 0,
    'Fleksibilitas': 0,
    'Problem Solving': 0,
    'Kepemimpinan': 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penilaian: ${widget.student.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ..._scores.keys.map((skill) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(skill, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _scores[skill]!,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    label: _scores[skill]!.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _scores[skill] = value;
                      });
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final scoredStudent = widget.student.copyWith();
                Navigator.pop(context, scoredStudent); // kembali ke assessment_page
              },
              child: const Text("Simpan dan Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}

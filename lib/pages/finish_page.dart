// lib/pages/finish_page.dart
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

// Model sederhana untuk siswa dan nilai
class StudentScore {
  final String name;
  final Map<String, String> scores; // aspek -> nilai ('Sangat Kurang' sampai 'Sangat Baik')

  StudentScore({required this.name, required this.scores});
}

class FinishPage extends StatelessWidget {
  final List<StudentScore> studentScores;
  final Map<String, Map<String, String>> answers;
  final List<String> aspects; // misal ['Fleksibilitas', 'Tanggung Jawab', 'Problem Solving', 'Komunikasi', 'Kerja Sama', 'Kepemimpinan']
  final String? schoolName;
  final String? className;
  final String? programName;
  final String? observerName;

  const FinishPage({
    Key? key, 
    required this.studentScores,
    required this.answers,
    required this.aspects,
    this.schoolName,
    this.className,
    this.programName,
    this.observerName,
  }) : super(key: key);

  // Method untuk generate PDF
  Future<void> _generatePDF() async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RINGKASAN PENILAIAN SOFT SKILLS',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Tanggal: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Sekolah: ${schoolName ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Kelas: ${className ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Program Keahlian: ${programName ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Observer: ${observerName ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Nama Siswa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        ...aspects.map((aspect) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(aspect, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        )).toList(),
                      ],
                    ),
                    // Data rows
                    ...studentScores.map((student) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(student.name),
                        ),
                        ...aspects.map((aspect) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(student.scores[aspect] ?? '-'),
                        )).toList(),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final schoolNameClean = (schoolName ?? 'Sekolah').replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = '${schoolNameClean}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      print('PDF file saved to: ${file.path}');
      
      // Buka file PDF
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        print('Error opening PDF file: ${result.message}');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }

  // Method untuk generate Excel dengan data mentah assessment
  Future<void> _generateExcel() async {
    try {
      // Buat Excel workbook baru
      var excel = Excel.createExcel();
      excel.delete('Sheet1'); // Hapus sheet default
      var sheet = excel['Data Assessment']; // Buat sheet dengan nama yang lebih baik
      
      // Informasi header
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('DATA ASSESSMENT SOFT SKILLS');
      sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Tanggal: ${DateTime.now().toString().split(' ')[0]}');
      sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Sekolah: ${schoolName ?? '-'}');
      sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Kelas: ${className ?? '-'}');
      sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Program Keahlian: ${programName ?? '-'}');
      sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Observer: ${observerName ?? '-'}');
      
      // Header tabel - Alur Pembelajaran, Butir Observasi, dan kolom untuk setiap siswa
      sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Alur Pembelajaran');
      sheet.cell(CellIndex.indexByString('B8')).value = TextCellValue('Butir Observasi');
      
      // Buat kolom untuk setiap siswa
      final students = answers.keys.toList();
      for (int i = 0; i < students.length; i++) {
        final column = String.fromCharCode(67 + i); // C, D, E, etc.
        sheet.cell(CellIndex.indexByString('${column}8')).value = TextCellValue(students[i]);
      }
      
      // Ambil semua butir observasi dari data answers
      final allObservations = <String>[];
      if (answers.isNotEmpty) {
        final firstStudent = students.first;
        final firstStudentAnswers = answers[firstStudent]!;
        allObservations.addAll(firstStudentAnswers.keys);
      }
      
      // Data butir observasi dan jawaban
      for (int i = 0; i < allObservations.length; i++) {
        final observation = allObservations[i];
        final row = i + 9; // Mulai dari baris 9
        
        // Parse alur pembelajaran dan butir observasi dari key
        final parts = observation.split('|');
        final alurPembelajaran = parts.length > 0 ? parts[0] : '';
        final butirObservasi = parts.length > 1 ? parts[1] : observation;
        
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(alurPembelajaran);
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(butirObservasi);
        
        // Jawaban setiap siswa untuk butir observasi ini
        for (int j = 0; j < students.length; j++) {
          final student = students[j];
          final column = String.fromCharCode(67 + j); // C, D, E, etc.
          final answer = answers[student]![observation] ?? '-';
          sheet.cell(CellIndex.indexByString('$column$row')).value = TextCellValue(answer);
        }
      }
      
      // Simpan file
      final output = await getApplicationDocumentsDirectory();
      final schoolNameClean = (schoolName ?? 'Sekolah').replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = '${schoolNameClean}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      
      // Encode dan simpan
      final bytes = excel.encode();
      if (bytes != null && bytes.isNotEmpty) {
        await file.writeAsBytes(bytes);
        
        // Buka file setelah disimpan
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          print('Error opening Excel file: ${result.message}');
        }
      } else {
        print('Error: Failed to encode Excel file');
      }
    } catch (e) {
      print('Error generating Excel: $e');
    }
  }

  // Method untuk share PDF
  Future<void> _sharePDF() async {
    try {
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'RINGKASAN PENILAIAN SOFT SKILLS',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Tanggal: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Sekolah: ${schoolName ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Kelas: ${className ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Program Keahlian: ${programName ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Observer: ${observerName ?? '-'}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Nama Siswa', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        ...aspects.map((aspect) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(aspect, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        )).toList(),
                      ],
                    ),
                    // Data rows
                    ...studentScores.map((student) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(student.name),
                        ),
                        ...aspects.map((aspect) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(student.scores[aspect] ?? '-'),
                        )).toList(),
                      ],
                    )).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final schoolNameClean = (schoolName ?? 'Sekolah').replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = '${schoolNameClean}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      
      // Share file
      await Share.shareXFiles([XFile(file.path)], text: 'Ringkasan Penilaian Soft Skills');
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }

  // Method untuk share Excel dengan data mentah assessment
  Future<void> _shareExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      
      // Informasi sekolah di baris pertama
      sheetObject.cell(CellIndex.indexByString('A1')).value = TextCellValue('DATA ASSESSMENT SOFT SKILLS');
      sheetObject.cell(CellIndex.indexByString('A2')).value = TextCellValue('Tanggal: ${DateTime.now().toString().split(' ')[0]}');
      sheetObject.cell(CellIndex.indexByString('A3')).value = TextCellValue('Sekolah: ${schoolName ?? '-'}');
      sheetObject.cell(CellIndex.indexByString('A4')).value = TextCellValue('Kelas: ${className ?? '-'}');
      sheetObject.cell(CellIndex.indexByString('A5')).value = TextCellValue('Program Keahlian: ${programName ?? '-'}');
      sheetObject.cell(CellIndex.indexByString('A6')).value = TextCellValue('Observer: ${observerName ?? '-'}');
      
      // Header tabel - Alur Pembelajaran, Butir Observasi, dan kolom untuk setiap siswa
      sheetObject.cell(CellIndex.indexByString('A8')).value = TextCellValue('Alur Pembelajaran');
      sheetObject.cell(CellIndex.indexByString('B8')).value = TextCellValue('Butir Observasi');
      
      // Buat kolom untuk setiap siswa
      final students = answers.keys.toList();
      for (int i = 0; i < students.length; i++) {
        final column = String.fromCharCode(67 + i); // C, D, E, etc.
        sheetObject.cell(CellIndex.indexByString('${column}8')).value = TextCellValue(students[i]);
      }
      
      // Ambil semua butir observasi dari data answers
      final allObservations = <String>[];
      if (answers.isNotEmpty) {
        final firstStudent = students.first;
        final firstStudentAnswers = answers[firstStudent]!;
        allObservations.addAll(firstStudentAnswers.keys);
      }
      
      // Data butir observasi dan jawaban
      for (int i = 0; i < allObservations.length; i++) {
        final observation = allObservations[i];
        final row = i + 9; // Mulai dari baris 9
        
        // Parse alur pembelajaran dan butir observasi dari key
        final parts = observation.split('|');
        final alurPembelajaran = parts.length > 0 ? parts[0] : '';
        final butirObservasi = parts.length > 1 ? parts[1] : observation;
        
        sheetObject.cell(CellIndex.indexByString('A$row')).value = TextCellValue(alurPembelajaran);
        sheetObject.cell(CellIndex.indexByString('B$row')).value = TextCellValue(butirObservasi);
        
        // Jawaban setiap siswa untuk butir observasi ini
        for (int j = 0; j < students.length; j++) {
          final student = students[j];
          final column = String.fromCharCode(67 + j); // C, D, E, etc.
          final answer = answers[student]![observation] ?? '-';
          sheetObject.cell(CellIndex.indexByString('$column$row')).value = TextCellValue(answer);
        }
      }
      
      final output = await getTemporaryDirectory();
      final schoolNameClean = (schoolName ?? 'Sekolah').replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '');
      final fileName = '${schoolNameClean}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File('${output.path}/$fileName');
      
      // Encode dan simpan file
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        
        // Share file
        await Share.shareXFiles([XFile(file.path)], text: 'Data Assessment Soft Skills');
      } else {
        print('Error: Failed to encode Excel file for sharing');
      }
    } catch (e) {
      print('Error sharing Excel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Penilaian'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 100,
            ),
            const SizedBox(height: 12),
            const Text(
              'Penilaian selesai!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Berikut ringkasan nilai semua siswa:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Tabel ringkasan nilai
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text('Nama Siswa')),
                    ...aspects.map((a) => DataColumn(label: Text(a))).toList(),
                  ],
                  rows: studentScores.map((student) {
                    return DataRow(
                      cells: [
                        DataCell(Text(student.name)),
                        ...aspects.map((aspect) => DataCell(Text(student.scores[aspect] ?? '-'))).toList(),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            
            // Tombol Simpan
            Text(
              'Simpan Hasil:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _generatePDF,
                  icon: Icon(Icons.picture_as_pdf, color: Colors.red),
                  label: Text('Simpan PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _generateExcel,
                  icon: Icon(Icons.table_chart, color: Colors.green),
                  label: Text('Simpan Data Assessment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tombol Share
            Text(
              'Bagikan Hasil:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _sharePDF,
                  icon: Icon(Icons.share, color: Colors.blue),
                  label: Text('Share PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                    foregroundColor: Colors.blue.shade700,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _shareExcel,
                  icon: Icon(Icons.share, color: Colors.orange),
                  label: Text('Share Data Assessment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Tombol Navigasi
            ElevatedButton(
              onPressed: () {
                // Kembali ke halaman CoverPage
                Navigator.of(context).pushNamedAndRemoveUntil('/cover', (route) => false);
              },
              child: const Text('Kembali ke Halaman Utama'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Alternatif keluar/login ulang
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text('Keluar / Login Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'chart_image_service.dart';

class PDFGenerationService {
  // Generate PDF untuk radar chart per siswa dengan saran AI
  static Future<String> generateStudentRadarPDF({
    required String studentName,
    required Map<String, double> studentScores,
    required List<String> aiSuggestions,
    String? schoolName,
    String? className,
    String? programName,
    String? observerName,
  }) async {
    try {
      // Generate chart image first
      final chartImageBytes =
          await ChartImageService.createRadarChartImage(studentScores);
      pw.MemoryImage? chartImage;
      print('=== CHART IMAGE DEBUG ===');
      print('Chart image bytes length: ${chartImageBytes.length}');
      print('Chart image bytes isNotEmpty: ${chartImageBytes.isNotEmpty}');
      
      if (chartImageBytes.isNotEmpty) {
        try {
          chartImage = pw.MemoryImage(chartImageBytes);
          print('Chart image created successfully: true');
        } catch (e) {
          print('Error creating MemoryImage: $e');
          chartImage = null;
        }
      } else {
        print(
            'Warning: Radar chart image for $studentName is empty, using fallback.');
      }
      print('Final chartImage is null: ${chartImage == null}');
      print('========================');

      final pdf = pw.Document();

      // Halaman 1: Cover dan Informasi Siswa
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'LAPORAN INDIVIDUAL SOFT SKILLS',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Analisis dan Saran Pengembangan',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Informasi Siswa
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMASI SISWA',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Nama Siswa', studentName),
                                _buildInfoRow('Kelas', className ?? '-'),
                                _buildInfoRow('Program', programName ?? '-'),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Sekolah', schoolName ?? '-'),
                                _buildInfoRow('Observer', observerName ?? '-'),
                                _buildInfoRow('Tanggal',
                                    DateTime.now().toString().split(' ')[0]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Ringkasan Skor
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RINGKASAN SKOR SOFT SKILLS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey400),
                        children: [
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.blue100),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text('Aspek',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text('Skor',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text('Kategori',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold)),
                              ),
                            ],
                          ),
                          ...studentScores.entries.map((entry) {
                            final aspect = entry.key;
                            final score = entry.value;
                            final category = _getCategory(score);
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(aspect),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(score.toStringAsFixed(1)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(category),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue200),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RADAR CHART - Profil Soft Skills',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      if (chartImage != null) ...[
                        pw.Text(
                          'DEBUG: Chart image is available, size: ${chartImage.bytes.length} bytes',
                          style: pw.TextStyle(fontSize: 8, color: PdfColors.red),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Center(
                          child: pw.Container(
                            width: 300,
                            height: 300,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.blue400, width: 2),
                              borderRadius: pw.BorderRadius.circular(8),
                              color: PdfColors.white,
                            ),
                            child: pw.Image(
                              chartImage,
                              width: 300,
                              height: 300,
                            ),
                          ),
                        ),
                      ]
                      else
                        pw.Container(
                          width: 320,
                          height: 320,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(8),
                            border: pw.Border.all(color: PdfColors.grey400, width: 2),
                          ),
                          child: pw.Center(
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'RADAR CHART',
                                  style: pw.TextStyle(
                                    color: PdfColors.blue800,
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  'Soft Skills Profile',
                                  style: pw.TextStyle(
                                    color: PdfColors.grey600,
                                    fontSize: 12,
                                  ),
                                ),
                                pw.SizedBox(height: 12),
                                // Show scores as text
                                ...studentScores.entries.map((entry) => 
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                                    child: pw.Row(
                                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          entry.key,
                                          style: pw.TextStyle(fontSize: 10),
                                        ),
                                        pw.Text(
                                          '${entry.value}',
                                          style: pw.TextStyle(
                                            fontSize: 10,
                                            fontWeight: pw.FontWeight.bold,
                                            color: PdfColors.blue800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).toList(),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Halaman 2: Saran AI
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'SARAN PENGEMBANGAN DARI AI',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.purple300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Rekomendasi untuk ${studentName}:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ...aiSuggestions
                          .map((suggestion) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 8),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      '- ',
                                      style: pw.TextStyle(
                                        color: PdfColors.purple600,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        suggestion,
                                        style: const pw.TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Analisis Detail
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ANALISIS DETAIL',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        _generateDetailedAnalysis(studentScores),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Simpan file
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Laporan_${studentName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      print('Error generating student radar PDF: $e');
      rethrow;
    }
  }

  // Generate PDF untuk ringkasan kelas
  static Future<String> generateClassSummaryPDF({
    required Map<String, Map<String, double>> studentScores,
    required List<String> classSuggestions,
    required String schoolName,
    required String className,
    required String programName,
    required String observerName,
  }) async {
    try {
      // Generate chart images first
      final classAverages = _calculateClassAverages(studentScores);
      final chartScores = _createChartScores(classAverages);
      final spiderChartBytes =
          await ChartImageService.createRadarChartImage(chartScores);
      final lineChartBytes =
          await ChartImageService.createLineChartImage(chartScores);

      // Validate chart images before using them
      pw.MemoryImage? spiderChartImage;
      pw.MemoryImage? lineChartImage;

      if (spiderChartBytes.isNotEmpty) {
        spiderChartImage = pw.MemoryImage(spiderChartBytes);
      } else {
        print('Warning: Spider chart image is empty, skipping chart display');
      }

      if (lineChartBytes.isNotEmpty) {
        lineChartImage = pw.MemoryImage(lineChartBytes);
      } else {
        print('Warning: Line chart image is empty, skipping chart display');
      }

      // Debug: Print received data
      print('=== DEBUG PDF GENERATION SERVICE ===');
      print('StudentScores received: ${studentScores.length}');
      for (final entry in studentScores.entries) {
        print('Student: ${entry.key}');
        print('Scores: ${entry.value}');
      }
      print('ClassSuggestions: $classSuggestions');
      print('====================================');

      final pdf = pw.Document();

      // Halaman 1: Cover dan Informasi Kelas
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'LAPORAN ANALISIS KELAS',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Soft Skills Assessment Report',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Informasi Kelas
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMASI KELAS',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Sekolah', schoolName),
                                _buildInfoRow('Kelas', className),
                                _buildInfoRow('Program', programName),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Observer', observerName),
                                _buildInfoRow(
                                    'Jumlah Siswa', '${studentScores.length}'),
                                _buildInfoRow('Tanggal',
                                    DateTime.now().toString().split(' ')[0]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Statistik Kelas
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STATISTIK KELAS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ..._generateClassStatistics(studentScores)
                          .map((stat) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 4),
                                child: pw.Text(stat,
                                    style: const pw.TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Halaman 2: Tabel Nilai Siswa
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TABEL NILAI SISWA',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    children: [
                      // Header
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.green100),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Nama Siswa',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          ...[
                            'Komunikasi',
                            'Kerja Sama',
                            'Tanggung Jawab',
                            'Fleksibilitas',
                            'Problem Solving',
                            'Kepemimpinan'
                          ]
                              .map((aspect) => pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(aspect,
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold)),
                                  ))
                              .toList(),
                        ],
                      ),
                      // Data rows
                      ...studentScores.entries.map((entry) {
                        final studentName = entry.key;
                        final scores = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(studentName),
                            ),
                            ...[
                              'Komunikasi',
                              'Kerja Sama',
                              'Tanggung Jawab',
                              'Fleksibilitas',
                              'Problem Solving',
                              'Kepemimpinan'
                            ].map((aspect) {
                              final score = _getAspectScore(scores, aspect);
                              return pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(score.toStringAsFixed(1)),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Halaman 3: Saran AI untuk Kelas
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'SARAN PENGEMBANGAN KELAS DARI AI',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.orange300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Rekomendasi untuk Kelas $className:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ...classSuggestions
                          .map((suggestion) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 8),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      '- ',
                                      style: pw.TextStyle(
                                        color: PdfColors.orange600,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        suggestion,
                                        style: const pw.TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Bar Chart
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.orange300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Grafik Rata-rata Kelas',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      // Spider Chart Visualization
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: PdfColors.orange300),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'SPIDER CHART - Class Performance',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.orange800,
                              ),
                            ),
                            pw.SizedBox(height: 12),
                            // Spider Chart Image
                            pw.Container(
                              padding: const pw.EdgeInsets.all(16),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.orange50,
                                borderRadius: pw.BorderRadius.circular(8),
                                border:
                                    pw.Border.all(color: PdfColors.orange300),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'SPIDER CHART - Class Performance',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.orange800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 12),
                                  if (spiderChartImage != null)
                                    pw.Center(
                                      child: pw.Image(
                                        spiderChartImage,
                                        width: 300,
                                        height: 300,
                                      ),
                                    )
                                  else
                                    pw.Container(
                                      width: 300,
                                      height: 300,
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.grey200,
                                        border: pw.Border.all(
                                            color: PdfColors.grey400),
                                      ),
                                      child: pw.Center(
                                        child: pw.Text(
                                          'Chart Preview\n(Image generation failed)',
                                          style: pw.TextStyle(
                                            color: PdfColors.grey600,
                                            fontSize: 12,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 12),
                            // Legend
                            pw.Wrap(
                              children: _calculateClassAverages(studentScores)
                                  .entries
                                  .map((entry) {
                                final aspect = entry.key;
                                final score = entry.value;

                                return pw.Container(
                                  margin: const pw.EdgeInsets.only(
                                      right: 8, bottom: 4),
                                  child: pw.Row(
                                    mainAxisSize: pw.MainAxisSize.min,
                                    children: [
                                      pw.Container(
                                        width: 12,
                                        height: 12,
                                        decoration: pw.BoxDecoration(
                                          color: PdfColors.orange,
                                          shape: pw.BoxShape.circle,
                                        ),
                                      ),
                                      pw.SizedBox(width: 4),
                                      pw.Text(
                                        '$aspect: ${score.toStringAsFixed(1)}',
                                        style: const pw.TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 16),

                      // Web Chart Visualization
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey100,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: PdfColors.green300),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'WEB CHART - Skills Distribution',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                              ),
                            ),
                            pw.SizedBox(height: 12),
                            // Web Chart Image (Line Chart)
                            pw.Container(
                              padding: const pw.EdgeInsets.all(16),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.green50,
                                borderRadius: pw.BorderRadius.circular(8),
                                border:
                                    pw.Border.all(color: PdfColors.green300),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'WEB CHART - Skills Distribution',
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.green800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 12),
                                  if (lineChartImage != null)
                                    pw.Center(
                                      child: pw.Image(
                                        lineChartImage,
                                        width: 400,
                                        height: 300,
                                      ),
                                    )
                                  else
                                    pw.Container(
                                      width: 400,
                                      height: 300,
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.grey200,
                                        border: pw.Border.all(
                                            color: PdfColors.grey400),
                                      ),
                                      child: pw.Center(
                                        child: pw.Text(
                                          'Chart Preview\n(Image generation failed)',
                                          style: pw.TextStyle(
                                            color: PdfColors.grey600,
                                            fontSize: 12,
                                          ),
                                          textAlign: pw.TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            pw.SizedBox(height: 12),
                            // Performance Summary
                            pw.Container(
                              padding: const pw.EdgeInsets.all(12),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.green50,
                                borderRadius: pw.BorderRadius.circular(6),
                              ),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Performance Summary:',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.green800,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  ..._calculateClassAverages(studentScores)
                                      .entries
                                      .map((entry) {
                                    final aspect = entry.key;
                                    final score = entry.value;
                                    final category = _getCategory(score);

                                    return pw.Text(
                                      '- $aspect: $category (${score.toStringAsFixed(1)})',
                                      style: const pw.TextStyle(fontSize: 10),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Analisis Kelas
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ANALISIS KELAS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        _generateClassAnalysis(studentScores),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Simpan file
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Laporan_Kelas_${className.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      print('Error generating class summary PDF: $e');
      rethrow;
    }
  }

  // Generate PDF untuk hasil penilaian soft skills (enhanced version)
  static Future<String> generateSoftSkillsResultsPDF({
    required List<Map<String, dynamic>> studentScores,
    required List<String> aspects,
    String? schoolName,
    String? className,
    String? programName,
    String? observerName,
  }) async {
    try {
      // Generate chart image first
      final classAverages = _calculateClassAveragesFromList(studentScores);
      final chartScores = _createChartScores(classAverages);
      final chartImageBytes =
          await ChartImageService.createBarChartImage(chartScores);
      pw.MemoryImage? chartImage;
      if (chartImageBytes.isNotEmpty) {
        chartImage = pw.MemoryImage(chartImageBytes);
      } else {
        print('Warning: Class bar chart image is empty, using fallback.');
      }

      final pdf = pw.Document();

      // Halaman 1: Cover
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'HASIL PENILAIAN SOFT SKILLS',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Assessment Report',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Informasi Assessment
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMASI ASSESSMENT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Sekolah', schoolName ?? '-'),
                                _buildInfoRow('Kelas', className ?? '-'),
                                _buildInfoRow('Program', programName ?? '-'),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Observer', observerName ?? '-'),
                                _buildInfoRow(
                                    'Jumlah Siswa', '${studentScores.length}'),
                                _buildInfoRow('Tanggal',
                                    DateTime.now().toString().split(' ')[0]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Tabel Ringkasan
                pw.Text(
                  'RINGKASAN NILAI SISWA',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    // Header
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.red100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Nama Siswa',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        ...aspects
                            .map((aspect) => pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(aspect,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ))
                            .toList(),
                      ],
                    ),
                    // Data rows
                    ...studentScores
                        .map((student) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(student['name'] ?? '-'),
                                ),
                                ...aspects
                                    .map((aspect) => pw.Padding(
                                          padding: const pw.EdgeInsets.all(8),
                                          child: pw.Text(student['scores']
                                                  ?[aspect] ??
                                              '-'),
                                        ))
                                    .toList(),
                              ],
                            ))
                        .toList(),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Bar Chart Preview
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.red300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GRAFIK RATA-RATA KELAS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      if (chartImage != null)
                        pw.Center(
                          child: pw.Container(
                            width: 400,
                            height: 300,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.red400, width: 2),
                              borderRadius: pw.BorderRadius.circular(8),
                              color: PdfColors.white,
                            ),
                            child: pw.Image(
                              chartImage,
                              width: 400,
                              height: 300,
                            ),
                          ),
                        )
                      else
                        pw.Container(
                          width: 360,
                          height: 270,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border.all(color: PdfColors.grey400),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'Chart tidak tersedia\n(Image generation failed)',
                              style: pw.TextStyle(
                                color: PdfColors.grey600,
                                fontSize: 12,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Simpan file
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Hasil_SoftSkills_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      print('Error generating soft skills results PDF: $e');
      rethrow;
    }
  }

  // Helper methods
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  static String _getCategory(double score) {
    if (score >= 4.5) return 'Sangat Baik';
    if (score >= 3.5) return 'Baik';
    if (score >= 2.5) return 'Cukup';
    if (score >= 1.5) return 'Kurang';
    return 'Sangat Kurang';
  }

  static double _getAspectScore(Map<String, double> scores, String aspect) {
    print('=== DEBUG _getAspectScore ===');
    print('Looking for aspect: $aspect');
    print('Available scores keys: ${scores.keys.toList()}');

    // First try direct match
    if (scores.containsKey(aspect)) {
      final score = scores[aspect]!;
      print('Direct match found: $score');
      return score;
    }

    // Try with aspect mapping
    final aspectMapping = {
      "Komunikasi": "KOM",
      "Kerja Sama": "KS",
      "Tanggung Jawab": "TJ",
      "Fleksibilitas": "FS",
      "Problem Solving": "PS",
      "Kepemimpinan": "KP"
    };

    final shortAspect = aspectMapping[aspect] ?? aspect;
    final aspectScores = <double>[];

    for (var entry in scores.entries) {
      if (entry.key.contains('($aspect)') || entry.key.contains(shortAspect)) {
        aspectScores.add(entry.value);
        print('Found matching key: ${entry.key} with value: ${entry.value}');
      }
    }

    if (aspectScores.isEmpty) {
      print('No scores found for aspect: $aspect, returning 0.0');
      return 0.0;
    }

    final avgScore = aspectScores.reduce((a, b) => a + b) / aspectScores.length;
    print('Average score for $aspect: $avgScore');
    print('============================');
    return avgScore;
  }

  static String _generateDetailedAnalysis(Map<String, double> studentScores) {
    final scores = studentScores.values.toList();
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    String analysis = 'Berdasarkan analisis data, siswa menunjukkan:\n\n';
    analysis += '- Skor rata-rata: ${avgScore.toStringAsFixed(1)}/5.0\n';
    analysis += '- Aspek terkuat: ${_getStrongestAspect(studentScores)}\n';
    analysis +=
        '- Aspek yang perlu ditingkatkan: ${_getWeakestAspect(studentScores)}\n';
    analysis +=
        '- Rentang skor: ${minScore.toStringAsFixed(1)} - ${maxScore.toStringAsFixed(1)}\n\n';

    if (avgScore >= 4.0) {
      analysis +=
          'Siswa menunjukkan performa yang sangat baik dalam soft skills.';
    } else if (avgScore >= 3.0) {
      analysis +=
          'Siswa menunjukkan performa yang baik dengan beberapa area yang dapat ditingkatkan.';
    } else if (avgScore >= 2.0) {
      analysis +=
          'Siswa menunjukkan performa yang cukup dengan banyak area yang perlu ditingkatkan.';
    } else {
      analysis +=
          'Siswa memerlukan bantuan intensif untuk mengembangkan soft skills.';
    }

    return analysis;
  }

  static List<String> _generateClassStatistics(
      Map<String, Map<String, double>> studentScores) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama',
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    final stats = <String>[];

    for (final aspect in aspects) {
      final scores = <double>[];
      for (final student in studentScores.values) {
        final score = _getAspectScore(student, aspect);
        scores.add(score);
      }

      if (scores.isNotEmpty) {
        final avg = scores.reduce((a, b) => a + b) / scores.length;
        final max = scores.reduce((a, b) => a > b ? a : b);
        final min = scores.reduce((a, b) => a < b ? a : b);

        stats.add(
            '$aspect: Rata-rata ${avg.toStringAsFixed(1)}, Range ${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}');
      } else {
        stats.add('$aspect: Tidak ada data');
      }
    }

    return stats;
  }

  static String _generateClassAnalysis(
      Map<String, Map<String, double>> studentScores) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama',
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    final classAverages = <String, double>{};

    for (final aspect in aspects) {
      final scores = <double>[];
      for (final student in studentScores.values) {
        final score = _getAspectScore(student, aspect);
        scores.add(score);
      }
      if (scores.isNotEmpty) {
        classAverages[aspect] = scores.reduce((a, b) => a + b) / scores.length;
      } else {
        classAverages[aspect] = 0.0;
      }
    }

    if (classAverages.isEmpty) {
      return 'Tidak ada data untuk dianalisis.';
    }

    final bestAspect =
        classAverages.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worstAspect =
        classAverages.entries.reduce((a, b) => a.value < b.value ? a : b);

    String analysis = 'Analisis Kelas:\n\n';
    analysis +=
        '- Aspek terkuat kelas: ${bestAspect.key} (${bestAspect.value.toStringAsFixed(1)}/5.0)\n';
    analysis +=
        '- Aspek yang perlu ditingkatkan: ${worstAspect.key} (${worstAspect.value.toStringAsFixed(1)}/5.0)\n';
    analysis += '- Jumlah siswa: ${studentScores.length}\n\n';

    final overallAvg =
        classAverages.values.reduce((a, b) => a + b) / classAverages.length;
    if (overallAvg >= 4.0) {
      analysis +=
          'Kelas menunjukkan performa soft skills yang sangat baik secara keseluruhan.';
    } else if (overallAvg >= 3.0) {
      analysis +=
          'Kelas menunjukkan performa soft skills yang baik dengan beberapa area yang dapat ditingkatkan.';
    } else {
      analysis +=
          'Kelas memerlukan program pengembangan soft skills yang intensif.';
    }

    return analysis;
  }

  static String _getStrongestAspect(Map<String, double> scores) {
    final entry = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  static String _getWeakestAspect(Map<String, double> scores) {
    final entry = scores.entries.reduce((a, b) => a.value < b.value ? a : b);
    return entry.key;
  }

  // Generate PDF lengkap dengan semua aspek
  static Future<String> generateCompletePDF({
    required Map<String, Map<String, double>> studentScores,
    required List<String> classSuggestions,
    required String schoolName,
    required String className,
    required String programName,
    required String observerName,
  }) async {
    try {
      // Generate chart images for individual students
      final studentScoresMap = _createChartScores(studentScores.values.first);
      final chartImageBytes =
          await ChartImageService.createRadarChartImage(studentScoresMap);

      // Validate chart image before using it
      print('=== COMPLETE PDF CHART DEBUG ===');
      print('Chart image bytes length: ${chartImageBytes.length}');
      print('Chart image bytes isNotEmpty: ${chartImageBytes.isNotEmpty}');
      
      pw.MemoryImage? chartImage;
      if (chartImageBytes.isNotEmpty) {
        try {
          chartImage = pw.MemoryImage(chartImageBytes);
          print('Complete PDF chart image created successfully: true');
        } catch (e) {
          print('Error creating MemoryImage for complete PDF: $e');
          chartImage = null;
        }
      } else {
        print('Warning: Chart image is empty, skipping chart display');
      }
      print('Final chartImage is null: ${chartImage == null}');
      print('================================');

      final pdf = pw.Document();

      // Halaman 1: Cover
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'LAPORAN LENGKAP SOFT SKILLS ASSESSMENT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Comprehensive Analysis Report',
                        style: pw.TextStyle(
                          fontSize: 16,
                          color: PdfColors.white,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Informasi Assessment
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INFORMASI ASSESSMENT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Sekolah', schoolName),
                                _buildInfoRow('Kelas', className),
                                _buildInfoRow('Program', programName),
                              ],
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Observer', observerName),
                                _buildInfoRow(
                                    'Jumlah Siswa', '${studentScores.length}'),
                                _buildInfoRow('Tanggal',
                                    DateTime.now().toString().split(' ')[0]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Statistik Kelas
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.indigo50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STATISTIK KELAS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ..._generateClassStatistics(studentScores)
                          .map((stat) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 4),
                                child: pw.Text(stat,
                                    style: const pw.TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Halaman 2: Tabel Nilai Siswa
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'TABEL NILAI SISWA',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Expanded(
                  child: pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    children: [
                      // Header
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.indigo100),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Nama Siswa',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          ...[
                            'Komunikasi',
                            'Kerja Sama',
                            'Tanggung Jawab',
                            'Fleksibilitas',
                            'Problem Solving',
                            'Kepemimpinan'
                          ]
                              .map((aspect) => pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(aspect,
                                        style: pw.TextStyle(
                                            fontWeight: pw.FontWeight.bold)),
                                  ))
                              .toList(),
                        ],
                      ),
                      // Data rows
                      ...studentScores.entries.map((entry) {
                        final studentName = entry.key;
                        final scores = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(studentName),
                            ),
                            ...[
                              'Komunikasi',
                              'Kerja Sama',
                              'Tanggung Jawab',
                              'Fleksibilitas',
                              'Problem Solving',
                              'Kepemimpinan'
                            ].map((aspect) {
                              final score = _getAspectScore(scores, aspect);
                              return pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(score.toStringAsFixed(1)),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Halaman 3: Saran AI untuk Kelas
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    'SARAN PENGEMBANGAN KELAS DARI AI',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.orange300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Rekomendasi untuk Kelas $className:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      ...classSuggestions
                          .map((suggestion) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 8),
                                child: pw.Row(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      '- ',
                                      style: pw.TextStyle(
                                        color: PdfColors.orange600,
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    pw.Expanded(
                                      child: pw.Text(
                                        suggestion,
                                        style: const pw.TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Analisis Kelas
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ANALISIS KELAS',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        _generateClassAnalysis(studentScores),
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Halaman 4-6: PDF Individual untuk setiap siswa
      for (final studentEntry in studentScores.entries) {
        final studentName = studentEntry.key;
        final scores = studentEntry.value;

        // Convert scores to the format needed for individual PDF
        final studentScoresMap = <String, double>{};
        for (final aspect in [
          'Komunikasi',
          'Kerja Sama',
          'Tanggung Jawab',
          'Fleksibilitas',
          'Problem Solving',
          'Kepemimpinan'
        ]) {
          final score = _getAspectScore(scores, aspect);
          studentScoresMap[aspect] = score;
        }

        // Generate AI suggestions for this student
        final aiSuggestions =
            _generateIndividualSuggestions(studentName, studentScoresMap);

        // Add individual student page
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.purple800,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'LAPORAN INDIVIDUAL SOFT SKILLS',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Analisis dan Saran Pengembangan',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Informasi Siswa
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INFORMASI SISWA',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Nama Siswa', studentName),
                                  _buildInfoRow('Kelas', className),
                                  _buildInfoRow('Program', programName),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Sekolah', schoolName),
                                  _buildInfoRow('Observer', observerName),
                                  _buildInfoRow('Tanggal',
                                      DateTime.now().toString().split(' ')[0]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Ringkasan Skor
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RINGKASAN SKOR SOFT SKILLS',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey400),
                          children: [
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.purple100),
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text('Aspek',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text('Skor',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text('Kategori',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                ),
                              ],
                            ),
                            ...studentScoresMap.entries.map((entry) {
                              final aspect = entry.key;
                              final score = entry.value;
                              final category = _getCategory(score);
                              return pw.TableRow(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(aspect),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(score.toStringAsFixed(1)),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.all(8),
                                    child: pw.Text(category),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Radar Chart
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.purple300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Radar Chart Soft Skills',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        // Radar Chart Visualization (Visual)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(16),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(8),
                            border: pw.Border.all(color: PdfColors.purple300),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'RADAR CHART - Soft Skills Profile',
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.purple800,
                                ),
                              ),
                              pw.SizedBox(height: 12),
                              // Radar Chart Image
                              pw.Container(
                                padding: const pw.EdgeInsets.all(16),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.blue50,
                                  borderRadius: pw.BorderRadius.circular(8),
                                  border:
                                      pw.Border.all(color: PdfColors.blue300),
                                ),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'RADAR CHART - Soft Skills Profile',
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.blue800,
                                      ),
                                    ),
                                    pw.SizedBox(height: 12),
                                    if (chartImage != null) ...[
                                      pw.Text(
                                        'DEBUG: Complete PDF chart available, size: ${chartImage.bytes.length} bytes',
                                        style: pw.TextStyle(fontSize: 8, color: PdfColors.red),
                                      ),
                                      pw.SizedBox(height: 8),
                                      pw.Center(
                                        child: pw.Container(
                                          width: 300,
                                          height: 300,
                                          decoration: pw.BoxDecoration(
                                            border: pw.Border.all(color: PdfColors.blue400, width: 2),
                                            borderRadius: pw.BorderRadius.circular(8),
                                            color: PdfColors.white,
                                          ),
                                          child: pw.Image(
                                            chartImage,
                                            width: 300,
                                            height: 300,
                                          ),
                                        ),
                                      ),
                                    ]
                                    else
                                      pw.Container(
                                        width: 300,
                                        height: 300,
                                        decoration: pw.BoxDecoration(
                                          color: PdfColors.grey200,
                                          border: pw.Border.all(
                                              color: PdfColors.grey400),
                                        ),
                                        child: pw.Center(
                                          child: pw.Text(
                                            'Chart Preview\n(Image generation failed)',
                                            style: pw.TextStyle(
                                              color: PdfColors.grey600,
                                              fontSize: 12,
                                            ),
                                            textAlign: pw.TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              pw.SizedBox(height: 12),
                              // Legend
                              pw.Wrap(
                                children: studentScoresMap.entries.map((entry) {
                                  final aspect = entry.key;
                                  final score = entry.value;

                                  return pw.Container(
                                    margin: const pw.EdgeInsets.only(
                                        right: 8, bottom: 4),
                                    child: pw.Row(
                                      mainAxisSize: pw.MainAxisSize.min,
                                      children: [
                                        pw.Container(
                                          width: 12,
                                          height: 12,
                                          decoration: pw.BoxDecoration(
                                            color: PdfColors.blue,
                                            shape: pw.BoxShape.circle,
                                          ),
                                        ),
                                        pw.SizedBox(width: 4),
                                        pw.Text(
                                          '$aspect: ${score.toStringAsFixed(1)}',
                                          style:
                                              const pw.TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Saran AI
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.purple300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Saran Pengembangan untuk $studentName:',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple800,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        ...aiSuggestions
                            .map((suggestion) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 8),
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '- ',
                                        style: pw.TextStyle(
                                          color: PdfColors.purple600,
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(
                                          suggestion,
                                          style:
                                              const pw.TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Simpan file
      final output = await getApplicationDocumentsDirectory();
      final fileName =
          'Laporan_Lengkap_${className.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      print('Error generating complete PDF: $e');
      rethrow;
    }
  }

  // Helper method untuk membuat data scores untuk chart
  static Map<String, double> _createChartScores(Map<String, double> originalScores) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama', 
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    
    final chartScores = <String, double>{};
    
    for (final aspect in aspects) {
      // Try to get score from original data
      double score = 0.0;
      
      // Direct match
      if (originalScores.containsKey(aspect)) {
        score = originalScores[aspect]!;
      } else {
        // Try to find any key that contains the aspect name
        for (final entry in originalScores.entries) {
          if (entry.key.toLowerCase().contains(aspect.toLowerCase()) ||
              entry.key.contains('KOM') && aspect == 'Komunikasi' ||
              entry.key.contains('KS') && aspect == 'Kerja Sama' ||
              entry.key.contains('TJ') && aspect == 'Tanggung Jawab' ||
              entry.key.contains('FS') && aspect == 'Fleksibilitas' ||
              entry.key.contains('PS') && aspect == 'Problem Solving' ||
              entry.key.contains('KP') && aspect == 'Kepemimpinan') {
            score = entry.value;
            break;
          }
        }
      }
      
      // If still no score found, use a default value
      if (score == 0.0) {
        score = 3.0; // Default to 'Cukup'
      }
      
      chartScores[aspect] = score;
    }
    
    print('Created chart scores: $chartScores');
    return chartScores;
  }

  // Helper method untuk generate individual suggestions
  static List<String> _generateIndividualSuggestions(
      String studentName, Map<String, double> scores) {
    final suggestions = <String>[];

    if (scores.isEmpty) {
      return ['Tidak ada data untuk dianalisis'];
    }

    final avgScore = scores.values.reduce((a, b) => a + b) / scores.length;

    if (avgScore >= 4.0) {
      suggestions.add('Pertahankan performa yang sangat baik di semua aspek');
      suggestions.add('Berbagi pengalaman dengan teman sekelas');
    } else if (avgScore >= 3.0) {
      suggestions.add('Fokus pada pengembangan aspek yang masih kurang');
      suggestions.add('Berpartisipasi lebih aktif dalam kegiatan kelompok');
    } else {
      suggestions
          .add('Perlu bimbingan intensif untuk mengembangkan soft skills');
      suggestions.add('Mulai dengan aspek yang paling mudah ditingkatkan');
    }

    // Add specific suggestions based on weakest aspect
    if (scores.isNotEmpty) {
      final weakestAspect =
          scores.entries.reduce((a, b) => a.value < b.value ? a : b);
      suggestions.add('Khususnya untuk ${weakestAspect.key}, coba latihan:');

      switch (weakestAspect.key) {
        case 'Komunikasi':
          suggestions.add('- Latihan presentasi di depan cermin');
          suggestions.add('- Berpartisipasi dalam diskusi kelompok');
          break;
        case 'Kerja Sama':
          suggestions.add('- Ikut serta dalam proyek kelompok');
          suggestions.add('- Belajar mendengarkan pendapat orang lain');
          break;
        case 'Tanggung Jawab':
          suggestions.add('- Menyelesaikan tugas tepat waktu');
          suggestions.add('- Melaporkan progress secara berkala');
          break;
        case 'Fleksibilitas':
          suggestions
              .add('- Mencoba pendekatan baru dalam menyelesaikan masalah');
          suggestions.add('- Beradaptasi dengan perubahan situasi');
          break;
        case 'Problem Solving':
          suggestions.add('- Latihan analisis masalah secara sistematis');
          suggestions.add('- Brainstorming solusi alternatif');
          break;
        case 'Kepemimpinan':
          suggestions.add('- Memimpin proyek kecil');
          suggestions.add('- Memberikan contoh yang baik');
          break;
      }
    }

    return suggestions;
  }

  // Helper method untuk menghitung class averages
  static Map<String, double> _calculateClassAverages(
      Map<String, Map<String, double>> studentScores) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama',
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    final classAverages = <String, double>{};

    for (final aspect in aspects) {
      final scores = <double>[];
      for (final student in studentScores.values) {
        final score = _getAspectScore(student, aspect);
        scores.add(score);
      }
      if (scores.isNotEmpty) {
        classAverages[aspect] = scores.reduce((a, b) => a + b) / scores.length;
      } else {
        classAverages[aspect] = 0.0;
      }
    }

    return classAverages;
  }

  // Helper method untuk menghitung class averages dari list
  static Map<String, double> _calculateClassAveragesFromList(
      List<Map<String, dynamic>> studentScores) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama',
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    final classAverages = <String, double>{};

    for (final aspect in aspects) {
      final scores = <double>[];
      for (final student in studentScores) {
        final scoreStr = student['scores']?[aspect] ?? 'Cukup';
        final score = _convertScoreToNumeric(scoreStr);
        scores.add(score);
      }
      if (scores.isNotEmpty) {
        classAverages[aspect] = scores.reduce((a, b) => a + b) / scores.length;
      } else {
        classAverages[aspect] = 0.0;
      }
    }

    return classAverages;
  }

  // Helper method untuk convert score string ke numeric
  static double _convertScoreToNumeric(String scoreStr) {
    switch (scoreStr.toLowerCase()) {
      case 'sangat baik':
        return 5.0;
      case 'baik':
        return 4.0;
      case 'cukup':
        return 3.0;
      case 'kurang':
        return 2.0;
      case 'sangat kurang':
        return 1.0;
      default:
        return 3.0; // Default to 'Cukup'
    }
  }

  // Method untuk membuka PDF
  static Future<void> openPDF(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        print('Error opening PDF file: ${result.message}');
      }
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  // Method untuk share PDF
  static Future<void> sharePDF(String filePath, String text) async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: text);
    } catch (e) {
      print('Error sharing PDF: $e');
    }
  }
}

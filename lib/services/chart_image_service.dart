import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ChartImageService {
  // Convert radar chart widget to image
  static Future<Uint8List> createRadarChartImage(
      Map<String, double> scores) async {
    try {
      const size = Size(300, 300);
      print('=== CREATING RADAR CHART ===');
      print('Scores received: $scores');
      print('Scores length: ${scores.length}');
      
      // Validate scores data
      if (scores.isEmpty) {
        print('Warning: No scores data provided, using fallback');
        return await _createFallbackImage(size);
      }

      // For emulator compatibility, use simple chart generation
      return await _createSimpleRadarChart(size, scores);
    } catch (e) {
      print('Error creating radar chart image: $e');
      return await _createFallbackImage(const Size(300, 300));
    }
  }

  // Convert bar chart widget to image
  static Future<Uint8List> createBarChartImage(
      Map<String, double> classAverages) async {
    try {
      const size = Size(400, 300);
      print('=== CREATING BAR CHART ===');
      print('Class averages received: $classAverages');
      print('Data length: ${classAverages.length}');
      
      // Validate data
      if (classAverages.isEmpty) {
        print('Warning: No class averages data provided, using fallback');
        return await _createFallbackImage(size);
      }

      // For emulator compatibility, use simple chart generation
      return await _createSimpleBarChart(size, classAverages);
    } catch (e) {
      print('Error creating bar chart image: $e');
      return await _createFallbackImage(const Size(400, 300));
    }
  }

  // Convert line chart widget to image
  static Future<Uint8List> createLineChartImage(
      Map<String, double> scores) async {
    try {
      const size = Size(400, 300);
      print('=== CREATING LINE CHART ===');
      print('Scores received: $scores');
      print('Data length: ${scores.length}');
      
      // Validate data
      if (scores.isEmpty) {
        print('Warning: No scores data provided, using fallback');
        return await _createFallbackImage(size);
      }

      // For emulator compatibility, use simple chart generation
      return await _createSimpleLineChart(size, scores);
    } catch (e) {
      print('Error creating line chart image: $e');
      return await _createFallbackImage(const Size(400, 300));
    }
  }

  // Create a bar chart using canvas drawing
  static Future<Uint8List> _createBarChartCanvas(
      Size size, Map<String, double> data) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

      // Draw title
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Class Average Scores',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          20,
        ),
      );

      // Draw bar chart
      _drawBarChart(canvas, size, data);

      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List() ?? Uint8List(0);
    } catch (e) {
      print('Error creating bar chart canvas: $e');
      return await _createFallbackImage(size);
    }
  }

  // Create a line chart using canvas drawing
  static Future<Uint8List> _createLineChartCanvas(
      Size size, Map<String, double> data) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

      // Draw title
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Skills Trend Line',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          20,
        ),
      );

      // Draw line chart
      _drawLineChart(canvas, size, data);

      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List() ?? Uint8List(0);
    } catch (e) {
      print('Error creating line chart canvas: $e');
      return await _createFallbackImage(size);
    }
  }

  // Create a radar chart using canvas drawing
  static Future<Uint8List> _createRadarChartCanvas(
      Size size, Map<String, double> scores) async {
    try {
      print('Drawing radar chart canvas with size: ${size.width}x${size.height}');
      print('Scores for radar chart: $scores');
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

      // Draw title
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Soft Skills Radar Chart',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          20,
        ),
      );

      // Draw radar chart with actual data
      _drawRadarChart(canvas, size, scores);

      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final result = byteData?.buffer.asUint8List() ?? Uint8List(0);
      print('Radar chart canvas completed, result size: ${result.length} bytes');
      return result;
    } catch (e) {
      print('Error creating radar chart canvas: $e');
      return await _createFallbackImage(size);
    }
  }

  // Draw bar chart
  static void _drawBarChart(
      Canvas canvas, Size size, Map<String, double> data) {
      final aspects = [
        'Komunikasi',
        'Kerja Sama',
        'Tanggung Jawab',
        'Fleksibilitas',
        'Problem Solving',
        'Kepemimpinan'
      ];

    final chartArea =
        Rect.fromLTWH(50, 60, size.width - 100, size.height - 120);
    final barWidth = chartArea.width / aspects.length * 0.6;
    final maxValue = 5.0; // Maximum score

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = chartArea.top + (chartArea.height * i / 5);
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }

    // Draw bars
    final barPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (int i = 0; i < aspects.length; i++) {
      final aspect = aspects[i];
      final value = data[aspect] ?? 0.0;
      final normalizedValue = value / maxValue;

      final barHeight = chartArea.height * normalizedValue;
      final barX = chartArea.left +
          (chartArea.width / aspects.length) * i +
          (chartArea.width / aspects.length - barWidth) / 2;
      final barY = chartArea.bottom - barHeight;

      // Draw bar
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        barPaint,
      );

      // Draw value label
      final valueTextPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueTextPainter.layout();
      valueTextPainter.paint(
        canvas,
        Offset(
          barX + barWidth / 2 - valueTextPainter.width / 2,
          barY - 15,
        ),
      );

      // Draw aspect label
      final aspectTextPainter = TextPainter(
        text: TextSpan(
          text: aspect,
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      aspectTextPainter.layout();
      aspectTextPainter.paint(
        canvas,
        Offset(
          barX + barWidth / 2 - aspectTextPainter.width / 2,
          chartArea.bottom + 5,
        ),
      );
    }
  }

  // Draw line chart
  static void _drawLineChart(
      Canvas canvas, Size size, Map<String, double> data) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama',
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];

    final chartArea =
        Rect.fromLTWH(50, 60, size.width - 100, size.height - 120);
    final maxValue = 5.0; // Maximum score

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = chartArea.top + (chartArea.height * i / 5);
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }

    // Draw line
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    bool isFirst = true;

    for (int i = 0; i < aspects.length; i++) {
      final aspect = aspects[i];
      final value = data[aspect] ?? 0.0;
      final normalizedValue = value / maxValue;

      final x = chartArea.left + (chartArea.width / (aspects.length - 1)) * i;
      final y = chartArea.bottom - (chartArea.height * normalizedValue);

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }

      // Draw data point
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // Draw value label
      final valueTextPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueTextPainter.layout();
      valueTextPainter.paint(
        canvas,
        Offset(x - valueTextPainter.width / 2, y - 15),
      );

      // Draw aspect label
      final aspectTextPainter = TextPainter(
        text: TextSpan(
          text: aspect,
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      aspectTextPainter.layout();
      aspectTextPainter.paint(
        canvas,
        Offset(x - aspectTextPainter.width / 2, chartArea.bottom + 5),
      );
    }

    // Draw the line
    canvas.drawPath(path, linePaint);
  }

  // Draw radar chart with actual data
  static void _drawRadarChart(
      Canvas canvas, Size size, Map<String, double> scores) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 20; // Offset for title
    final radius = math.min(size.width, size.height) / 3;

      final aspects = [
        'Komunikasi',
        'Kerja Sama',
        'Tanggung Jawab',
        'Fleksibilitas',
        'Problem Solving',
        'Kepemimpinan'
      ];

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      final r = radius * i / 5;
      canvas.drawCircle(Offset(centerX, centerY), r, gridPaint);
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw 6 axes (for 6 aspects)
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      canvas.drawLine(Offset(centerX, centerY), Offset(x, y), axisPaint);

      // Draw aspect labels
      final labelX = centerX + (radius + 20) * math.cos(angle);
      final labelY = centerY + (radius + 20) * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: aspects[i],
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }

    // Draw data points using actual scores
    final dataPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    bool isFirst = true;

    for (int i = 0; i < 6; i++) {
      final aspect = aspects[i];
      final score = scores[aspect] ?? 0.0;
      final normalizedScore = score / 5.0; // Normalize to 0-1 range

      final angle = (i * math.pi * 2) / 6;
      final x = centerX + radius * normalizedScore * math.cos(angle);
      final y = centerY + radius * normalizedScore * math.sin(angle);

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }

      // Draw data point
      canvas.drawCircle(Offset(x, y), 4, dataPaint);
    }
    path.close();

    // Fill the area
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);
  }

  // Create simple bar chart for emulator compatibility
  static Future<Uint8List> _createSimpleBarChart(Size size, Map<String, double> data) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
      
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
      
      // Draw title
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Class Average Scores',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          20,
        ),
      );
      
      // Draw simple bar chart
      _drawSimpleBarChart(canvas, size, data);
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      final result = byteData?.buffer.asUint8List() ?? Uint8List(0);
      print('Simple bar chart created, size: ${result.length} bytes');
      print('Image dimensions: ${size.width.toInt()}x${size.height.toInt()}');
      print('Byte data format: PNG');
      return result;
    } catch (e) {
      print('Error creating simple bar chart: $e');
      return await _createFallbackImage(size);
    }
  }

  // Create simple line chart for emulator compatibility
  static Future<Uint8List> _createSimpleLineChart(Size size, Map<String, double> data) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
      
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
      
      // Draw title
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Skills Trend Line',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          20,
        ),
      );
      
      // Draw simple line chart
      _drawSimpleLineChart(canvas, size, data);
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      final result = byteData?.buffer.asUint8List() ?? Uint8List(0);
      print('Simple line chart created, size: ${result.length} bytes');
      print('Image dimensions: ${size.width.toInt()}x${size.height.toInt()}');
      print('Byte data format: PNG');
      return result;
    } catch (e) {
      print('Error creating simple line chart: $e');
      return await _createFallbackImage(size);
    }
  }

  // Create simple radar chart for emulator compatibility
  static Future<Uint8List> _createSimpleRadarChart(Size size, Map<String, double> scores) async {
    try {
      print('Creating simple radar chart with size: ${size.width}x${size.height}');
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
      
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
      
      // Draw title
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'RADAR CHART',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          2,
        ),
      );
      
      // Draw very simple radar chart
      _drawVerySimpleRadarChart(canvas, size, scores);
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      final result = byteData?.buffer.asUint8List() ?? Uint8List(0);
      print('Simple radar chart created, size: ${result.length} bytes');
      print('Image dimensions: ${size.width.toInt()}x${size.height.toInt()}');
      print('Byte data format: PNG');
      
      // Validate image data
      if (result.isEmpty) {
        print('ERROR: Chart image is empty!');
        return await _createFallbackImage(size);
      }
      
      // Check if image has valid PNG header
      if (result.length < 8 || result[0] != 0x89 || result[1] != 0x50 || result[2] != 0x4E || result[3] != 0x47) {
        print('ERROR: Invalid PNG format!');
        return await _createFallbackImage(size);
      }
      
      print('Chart image validation passed');
      print('Final chart image size: ${result.length} bytes');
      print('First 10 bytes: ${result.take(10).toList()}');
      
      // Try to create a smaller image for better PDF compatibility
      if (result.length > 100000) { // If image is too large
        print('Image too large, creating smaller version');
        final smallerSize = Size(250, 250);
        return await _createSmallerRadarChart(smallerSize, scores);
      }
      
      return result;
    } catch (e) {
      print('Error creating simple radar chart: $e');
      return await _createFallbackImage(size);
    }
  }

  // Draw simple bar chart
  static void _drawSimpleBarChart(Canvas canvas, Size size, Map<String, double> data) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama', 
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    
    final chartArea = Rect.fromLTWH(50, 60, size.width - 100, size.height - 120);
    final barWidth = chartArea.width / aspects.length * 0.6;
    final maxValue = 5.0;
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i <= 5; i++) {
      final y = chartArea.top + (chartArea.height * i / 5);
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }
    
    // Draw bars
    final barPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < aspects.length; i++) {
      final aspect = aspects[i];
      final value = data[aspect] ?? 0.0;
      final normalizedValue = value / maxValue;
      
      final barHeight = chartArea.height * normalizedValue;
      final barX = chartArea.left + (chartArea.width / aspects.length) * i + 
                   (chartArea.width / aspects.length - barWidth) / 2;
      final barY = chartArea.bottom - barHeight;
      
      // Draw bar
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        barPaint,
      );
      
      // Draw value label
      final valueTextPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueTextPainter.layout();
      valueTextPainter.paint(
        canvas,
        Offset(
          barX + barWidth / 2 - valueTextPainter.width / 2,
          barY - 15,
        ),
      );
      
      // Draw aspect label
      final aspectTextPainter = TextPainter(
        text: TextSpan(
          text: aspect,
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
          textDirection: TextDirection.ltr,
      );
      aspectTextPainter.layout();
      aspectTextPainter.paint(
        canvas,
        Offset(
          barX + barWidth / 2 - aspectTextPainter.width / 2,
          chartArea.bottom + 5,
        ),
      );
    }
  }

  // Draw simple line chart
  static void _drawSimpleLineChart(Canvas canvas, Size size, Map<String, double> data) {
    final aspects = [
      'Komunikasi',
      'Kerja Sama', 
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    
    final chartArea = Rect.fromLTWH(50, 60, size.width - 100, size.height - 120);
    final maxValue = 5.0;
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i <= 5; i++) {
      final y = chartArea.top + (chartArea.height * i / 5);
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
    }
    
    // Draw line
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path();
    bool isFirst = true;
    
    for (int i = 0; i < aspects.length; i++) {
      final aspect = aspects[i];
      final value = data[aspect] ?? 0.0;
      final normalizedValue = value / maxValue;
      
      final x = chartArea.left + (chartArea.width / (aspects.length - 1)) * i;
      final y = chartArea.bottom - (chartArea.height * normalizedValue);
      
      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
      
      // Draw data point
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      
      // Draw value label
      final valueTextPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueTextPainter.layout();
      valueTextPainter.paint(
        canvas,
        Offset(x - valueTextPainter.width / 2, y - 15),
      );
      
      // Draw aspect label
      final aspectTextPainter = TextPainter(
        text: TextSpan(
          text: aspect,
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      aspectTextPainter.layout();
      aspectTextPainter.paint(
        canvas,
        Offset(x - aspectTextPainter.width / 2, chartArea.bottom + 5),
      );
    }
    
    // Draw the line
    canvas.drawPath(path, linePaint);
  }

  // Create smaller radar chart for better PDF compatibility
  static Future<Uint8List> _createSmallerRadarChart(Size size, Map<String, double> scores) async {
    try {
      print('Creating smaller radar chart with size: ${size.width}x${size.height}');
      
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      
      // Draw background
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
      
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
      
      // Draw simple radar chart
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      final radius = math.min(size.width, size.height) / 4;
      
      // Draw circle
      final circlePaint = Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);
      
      // Draw data points
      final aspects = ['Komunikasi', 'Kerja Sama', 'Tanggung Jawab', 'Fleksibilitas', 'Problem Solving', 'Kepemimpinan'];
      
      for (int i = 0; i < 6; i++) {
        final score = scores[aspects[i]] ?? 0.0;
        final normalizedScore = score / 5.0;
        final angle = (i * math.pi * 2) / 6;
        final x = centerX + radius * normalizedScore * math.cos(angle);
        final y = centerY + radius * normalizedScore * math.sin(angle);
        
        // Draw data point
        final pointPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final result = byteData?.buffer.asUint8List() ?? Uint8List(0);
      print('Smaller radar chart created, size: ${result.length} bytes');
      return result;
    } catch (e) {
      print('Error creating smaller radar chart: $e');
      return await _createFallbackImage(size);
    }
  }

  // Draw very simple radar chart
  static void _drawVerySimpleRadarChart(Canvas canvas, Size size, Map<String, double> scores) {
    print('Drawing very simple radar chart');
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 3;
    
    // Draw simple circle
    final circlePaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);
    
    // Draw simple data points
    final aspects = ['Komunikasi', 'Kerja Sama', 'Tanggung Jawab', 'Fleksibilitas', 'Problem Solving', 'Kepemimpinan'];
    
    for (int i = 0; i < 6; i++) {
      final score = scores[aspects[i]] ?? 0.0;
      final normalizedScore = score / 5.0;
      final angle = (i * math.pi * 2) / 6;
      final x = centerX + radius * normalizedScore * math.cos(angle);
      final y = centerY + radius * normalizedScore * math.sin(angle);
      
      // Draw data point
      final pointPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
    }
    
    print('Very simple radar chart completed');
  }

  // Draw simple radar chart
  static void _drawSimpleRadarChart(Canvas canvas, Size size, Map<String, double> scores) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 + 20;
    final radius = math.min(size.width, size.height) / 3;
    
    final aspects = [
      'Komunikasi',
      'Kerja Sama', 
      'Tanggung Jawab',
      'Fleksibilitas',
      'Problem Solving',
      'Kepemimpinan'
    ];
    
    // Draw grid circles
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 1; i <= 5; i++) {
      final r = radius * i / 5;
      canvas.drawCircle(Offset(centerX, centerY), r, gridPaint);
    }
    
    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      canvas.drawLine(Offset(centerX, centerY), Offset(x, y), axisPaint);
    }
    
    // Draw data points and connect them
    final dataPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path();
    bool isFirst = true;
    
    for (int i = 0; i < 6; i++) {
      final aspect = aspects[i];
      final score = scores[aspect] ?? 0.0;
      final normalizedScore = score / 5.0;
      
      final angle = (i * math.pi * 2) / 6;
      final x = centerX + radius * normalizedScore * math.cos(angle);
      final y = centerY + radius * normalizedScore * math.sin(angle);
      
      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
      
      // Draw data point
      canvas.drawCircle(Offset(x, y), 5, dataPaint);
    }
    path.close();
    
    // Fill the area
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
    
    // Draw border
    canvas.drawPath(path, linePaint);
    
    // Draw labels
    for (int i = 0; i < 6; i++) {
      final aspect = aspects[i];
      final angle = (i * math.pi * 2) / 6;
      final x = centerX + (radius + 30) * math.cos(angle);
      final y = centerY + (radius + 30) * math.sin(angle);
      
      final labelPainter = TextPainter(
        text: TextSpan(
          text: aspect,
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, y - labelPainter.height / 2),
      );
    }
  }

  // Create a fallback image when chart generation fails
  static Future<Uint8List> _createFallbackImage(Size size) async {
    try {
      // Create a simple colored rectangle as fallback
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background
      final paint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
          Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

      // Draw text
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Chart Preview\n(Image generation failed)',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );

      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List() ?? Uint8List(0);
    } catch (e) {
      print('Error creating fallback image: $e');
      return Uint8List(0);
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class AISuggestionService {
  static const String _apiKey = "AIzaSyCH66wal927bMKuOIFvZirUwumd4ih2nt8";
  static const String _endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

  // Fungsi untuk mendapatkan saran AI untuk siswa individual
  static Future<List<String>> getIndividualSuggestions({
    required String studentName,
    required Map<String, double> aspectScores,
  }) async {
    try {
      print('=== GETTING INDIVIDUAL SUGGESTIONS ===');
      print('Student Name: $studentName');
      print('Aspect Scores: $aspectScores');
      
      // Cek apakah data seimbang
      final scores = aspectScores.values.toList();
      final maxScore = scores.reduce((a, b) => a > b ? a : b);
      final minScore = scores.reduce((a, b) => a < b ? a : b);
      final isBalanced = (maxScore - minScore) <= 0.5;
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      
      print('Data Analysis:');
      print('  Max Score: $maxScore');
      print('  Min Score: $minScore');
      print('  Average Score: ${avgScore.toStringAsFixed(1)}');
      print('  Is Balanced: $isBalanced (difference: ${(maxScore - minScore).toStringAsFixed(1)})');
      
      final prompt = _buildIndividualPrompt(studentName, aspectScores);
      print('Generated Prompt: $prompt');
      
      final response = await _callGeminiAPI(prompt);
      final suggestions = _parseSuggestions(response);
      
      print('Final suggestions returned: $suggestions');
      print('=====================================');
      
      return suggestions;
    } catch (e) {
      print('Error getting individual suggestions: $e');
      return _getFallbackSuggestions(aspectScores);
    }
  }

  // Fungsi untuk mendapatkan analisa dan saran untuk kelas
  static Future<List<String>> getClassAnalysis(
    Map<String, Map<String, double>> studentScores,
    String className,
  ) async {
    try {
      // Hitung rata-rata kelas untuk setiap aspek
      final classAverages = <String, double>{};
      final aspects = ["KOM", "KS", "TJ", "FS", "PS", "KP"];
      final aspectNames = ["Komunikasi", "Kerja Sama", "Tanggung Jawab", "Fleksibilitas", "Problem Solving", "Kepemimpinan"];
      
      for (int i = 0; i < aspects.length; i++) {
        final aspect = aspects[i];
        final aspectName = aspectNames[i];
        double total = 0;
        int count = 0;
        
        for (var studentName in studentScores.keys) {
          final scores = studentScores[studentName]!;
          final value = _getScoreForAspect(aspect, scores);
          if (value > 0) {
            total += value;
            count++;
          }
        }
        
        classAverages[aspectName] = count > 0 ? total / count : 0.0;
      }
      
      final prompt = _buildClassPrompt(className, classAverages);
      final response = await _callGeminiAPI(prompt);
      final analysis = _parseClassAnalysis(response);
      
      // Konversi ke List<String>
      final suggestions = <String>[];
      suggestions.add(analysis['analisa_kelas'] ?? '');
      suggestions.add('Aspek terlemah: ${analysis['aspek_terlemah_kelas'] ?? 'Tidak dapat ditentukan'}');
      
      final recommendations = List<String>.from(analysis['rekomendasi_guru'] ?? []);
      final activities = List<String>.from(analysis['kegiatan_perbaikan'] ?? []);
      
      suggestions.addAll(recommendations);
      suggestions.addAll(activities);
      
      return suggestions.where((s) => s.isNotEmpty).toList();
    } catch (e) {
      print('Error getting class analysis: $e');
      return _getFallbackClassAnalysisList(studentScores);
    }
  }

  // Fungsi untuk memanggil Gemini API
  static Future<String> _callGeminiAPI(String prompt) async {
    final url = Uri.parse('$_endpoint?key=$_apiKey');
    
    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": prompt
            }
          ]
        }
      ]
    };

    // Print payload yang dikirim
    print('=== GEMINI API REQUEST ===');
    print('URL: $url');
    print('Headers:');
    print('  Content-Type: application/json');
    print('  x-goog-api-key: $_apiKey');
    print('Payload:');
    print(jsonEncode(requestBody));
    print('========================');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': _apiKey,
      },
      body: jsonEncode(requestBody),
    );

    // Print response yang diterima
    print('=== GEMINI API RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body:');
    print(response.body);
    print('==========================');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final responseText = data['candidates'][0]['content']['parts'][0]['text'];
      
      // Print extracted text
      print('=== EXTRACTED TEXT ===');
      print(responseText);
      print('======================');
      
      return responseText;
    } else {
      throw Exception('API call failed: ${response.statusCode}');
    }
  }

  // Fungsi untuk membuat prompt untuk analisa individual
  static String _buildIndividualPrompt(String studentName, Map<String, double> aspectScores) {
    final scoresText = aspectScores.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}')
        .join(', ');

    // Cek apakah data seimbang
    final scores = aspectScores.values.toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final isBalanced = (maxScore - minScore) <= 0.5;
    
    String balanceContext = '';
    if (isBalanced) {
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      if (avgScore <= 2.0) {
        balanceContext = 'CATATAN: Semua aspek memiliki skor rendah dan seimbang. Siswa membutuhkan pengembangan menyeluruh di semua aspek.';
      } else if (avgScore <= 3.0) {
        balanceContext = 'CATATAN: Semua aspek memiliki skor sedang dan seimbang. Siswa membutuhkan peningkatan konsisten di semua aspek.';
      } else if (avgScore <= 4.0) {
        balanceContext = 'CATATAN: Semua aspek memiliki skor baik dan seimbang. Siswa membutuhkan penguatan dan tantangan lebih di semua aspek.';
      } else {
        balanceContext = 'CATATAN: Semua aspek memiliki skor sangat baik dan seimbang. Siswa siap untuk tantangan advanced di semua aspek.';
      }
    }

    return '''
Sebagai konselor pendidikan, analisislah data soft skills siswa dan berikan saran yang SINGKAT, JELAS, dan MUDAH DIPAHAMI:

Nama Siswa: $studentName
Data Skor Soft Skills: $scoresText

${balanceContext.isNotEmpty ? balanceContext : ''}

Aspek yang dinilai:
- Komunikasi: Kemampuan berkomunikasi efektif
- Kerja Sama: Kemampuan bekerja dalam tim
- Tanggung Jawab: Kemampuan bertanggung jawab
- Fleksibilitas: Kemampuan beradaptasi
- Problem Solving: Kemampuan memecahkan masalah
- Kepemimpinan: Kemampuan memimpin

Skala: 1.0 (Sangat Kurang) - 5.0 (Sangat Baik)

INSTRUKSI KHUSUS:
- Berikan saran yang SINGKAT (maksimal 1 kalimat per saran)
- Gunakan bahasa yang MUDAH DIPAHAMI siswa
- Fokus pada hal yang PRAKTIS dan bisa langsung diterapkan
- Jika data seimbang, berikan saran untuk pengembangan menyeluruh

Format JSON:
{
  "analisa": "Analisis singkat kondisi siswa (1-2 kalimat)",
  "saran": [
    "Saran singkat 1",
    "Saran singkat 2", 
    "Saran singkat 3",
    "Saran singkat 4"
  ]
}
''';
  }

  // Fungsi untuk membuat prompt untuk analisa kelas
  static String _buildClassPrompt(String className, Map<String, double> classAverages) {
    final averagesText = classAverages.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)}')
        .join(', ');

    return '''
Sebagai konselor pendidikan, analisislah data soft skills kelas berikut dan berikan rekomendasi untuk perbaikan pembelajaran:

Kelas: $className
Rata-rata Skor Soft Skills Kelas: $averagesText

Aspek yang dinilai:
- Komunikasi (KOM): Kemampuan berkomunikasi efektif
- Kerja Sama (KS): Kemampuan bekerja dalam tim  
- Tanggung Jawab (TJ): Kemampuan bertanggung jawab
- Fleksibilitas (FS): Kemampuan beradaptasi
- Problem Solving (PS): Kemampuan memecahkan masalah
- Kepemimpinan (KP): Kemampuan memimpin

Skala penilaian: 1.0 (Sangat Kurang) - 5.0 (Sangat Baik)

Berikan respons dalam format JSON:
{
  "analisa_kelas": "Analisis umum tentang kondisi soft skills kelas",
  "aspek_terlemah_kelas": "Aspek yang paling lemah di kelas",
  "rekomendasi_guru": [
    "Rekomendasi untuk guru 1",
    "Rekomendasi untuk guru 2",
    "Rekomendasi untuk guru 3"
  ],
  "kegiatan_perbaikan": [
    "Kegiatan perbaikan 1",
    "Kegiatan perbaikan 2",
    "Kegiatan perbaikan 3"
  ]
}
''';
  }

  // Fungsi untuk parsing response individual
  static List<String> _parseSuggestions(String response) {
    try {
      print('=== PARSING SUGGESTIONS ===');
      print('Raw response: $response');
      
      // Cari JSON dalam response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      print('JSON start: $jsonStart, JSON end: $jsonEnd');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        print('Extracted JSON: $jsonString');
        
        final data = jsonDecode(jsonString);
        print('Parsed data: $data');
        
        final suggestions = List<String>.from(data['saran'] ?? []);
        print('Final suggestions: $suggestions');
        print('========================');
        
        return suggestions;
      }
    } catch (e) {
      print('Error parsing suggestions: $e');
      print('========================');
    }
    
    return ['Gagal memproses saran AI. Silakan coba lagi.'];
  }

  // Fungsi untuk parsing response kelas
  static Map<String, dynamic> _parseClassAnalysis(String response) {
    try {
      // Cari JSON dalam response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonString);
      }
    } catch (e) {
      print('Error parsing class analysis: $e');
    }
    
    return {
      'analisa_kelas': 'Gagal memproses analisa AI.',
      'aspek_terlemah_kelas': 'Tidak dapat ditentukan',
      'rekomendasi_guru': ['Silakan coba lagi nanti.'],
      'kegiatan_perbaikan': ['Silakan coba lagi nanti.']
    };
  }

  // Fallback suggestions jika API gagal
  static List<String> _getFallbackSuggestions(Map<String, double> aspectScores) {
    // Cek apakah data seimbang
    final scores = aspectScores.values.toList();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final isBalanced = (maxScore - minScore) <= 0.5;
    
    if (isBalanced) {
      final avgScore = scores.reduce((a, b) => a + b) / scores.length;
      if (avgScore <= 2.0) {
        return [
          'Luangkan waktu lebih banyak untuk belajar semua aspek soft skills',
          'Ikuti program mentoring untuk pengembangan menyeluruh',
          'Praktikkan keterampilan dasar di kehidupan sehari-hari',
          'Minta bimbingan guru untuk strategi belajar yang efektif',
        ];
      } else if (avgScore <= 3.0) {
        return [
          'Tingkatkan konsistensi dalam menerapkan soft skills',
          'Ambil tantangan baru untuk mengembangkan semua aspek',
          'Bergabung dengan kegiatan ekstrakurikuler yang bervariasi',
          'Refleksikan perkembangan diri secara berkala',
        ];
      } else if (avgScore <= 4.0) {
        return [
          'Terus tingkatkan kualitas penerapan soft skills',
          'Ambil peran leadership dalam berbagai kegiatan',
          'Bantu teman yang masih kesulitan mengembangkan soft skills',
          'Cari tantangan yang lebih kompleks untuk semua aspek',
        ];
      } else {
        return [
          'Siap untuk tantangan advanced di semua aspek soft skills',
          'Menjadi mentor untuk teman yang masih berkembang',
          'Ambil proyek yang menantang untuk mengasah kemampuan',
          'Terus berinovasi dalam penerapan soft skills',
        ];
      }
    }
    
    // Jika tidak seimbang, cari aspek terlemah
    String? weakestAspect;
    double lowestScore = 5.0;
    
    aspectScores.forEach((aspect, score) {
      if (score < lowestScore) {
        lowestScore = score;
        weakestAspect = aspect;
      }
    });

    switch (weakestAspect) {
      case 'Komunikasi':
        return [
          'Latih berbicara di depan kelas secara rutin',
          'Ikuti kegiatan debat untuk meningkatkan kepercayaan diri',
          'Baca buku untuk memperkaya kosakata',
          'Praktikkan komunikasi aktif dengan teman',
        ];
      case 'Kerja Sama':
        return [
          'Aktif berpartisipasi dalam kegiatan kelompok',
          'Belajar mendengarkan pendapat orang lain',
          'Terlibat dalam proyek kolaboratif di sekolah',
          'Kembangkan sikap empati dan saling menghargai',
        ];
      case 'Tanggung Jawab':
        return [
          'Buat jadwal harian dan patuhi dengan konsisten',
          'Selesaikan tugas tepat waktu tanpa diingatkan',
          'Ambil inisiatif membantu teman yang kesulitan',
          'Refleksikan tindakan dan belajar dari kesalahan',
        ];
      case 'Fleksibilitas':
        return [
          'Terima perubahan dengan pikiran terbuka',
          'Coba metode belajar yang berbeda-beda',
          'Hadapi tantangan baru dengan antusias',
          'Beradaptasi dengan lingkungan dan situasi baru',
        ];
      case 'Problem Solving':
        return [
          'Latih kemampuan analisis dengan memecahkan puzzle',
          'Belajar mengidentifikasi akar masalah sebelum mencari solusi',
          'Kembangkan kreativitas melalui brainstorming',
          'Praktikkan pendekatan sistematis dalam menyelesaikan masalah',
        ];
      case 'Kepemimpinan':
        return [
          'Ambil peran sebagai ketua kelompok dalam proyek sekolah',
          'Latih kemampuan memotivasi dan menginspirasi teman',
          'Kembangkan visi dan kemampuan merencanakan',
          'Belajar mengambil keputusan yang tepat untuk tim',
        ];
      default:
        return [
          'Fokus pada pengembangan diri secara konsisten',
          'Cari mentor atau guru yang bisa memberikan bimbingan',
          'Ikuti pelatihan atau workshop soft skills',
          'Praktikkan keterampilan baru dalam kehidupan sehari-hari',
        ];
    }
  }

  // Fungsi untuk mendapatkan skor aspek dari data siswa
  static double _getScoreForAspect(String aspect, Map<String, double> studentScoreData) {
    final aspectMapping = {
      "KOM": "Komunikasi",
      "KS": "Kerja Sama", 
      "TJ": "Tanggung Jawab",
      "FS": "Fleksibilitas",
      "PS": "Problem Solving",
      "KP": "Kepemimpinan",
    };
    
    final fullAspect = aspectMapping[aspect] ?? aspect;
    
    // Kumpulkan semua nilai untuk aspek ini dari semua tahap
    final scores = <double>[];
    for (var entry in studentScoreData.entries) {
      if (entry.key.contains('($fullAspect)')) {
        scores.add(entry.value);
      }
    }
    
    // Hitung rata-rata dari semua tahap
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }


  // Fallback class analysis list jika API gagal
  static List<String> _getFallbackClassAnalysisList(Map<String, Map<String, double>> studentScores) {
    // Hitung rata-rata kelas
    final classAverages = <String, double>{};
    final aspects = ["KOM", "KS", "TJ", "FS", "PS", "KP"];
    final aspectNames = ["Komunikasi", "Kerja Sama", "Tanggung Jawab", "Fleksibilitas", "Problem Solving", "Kepemimpinan"];
    
    for (int i = 0; i < aspects.length; i++) {
      final aspect = aspects[i];
      final aspectName = aspectNames[i];
      double total = 0;
      int count = 0;
      
      for (var studentName in studentScores.keys) {
        final scores = studentScores[studentName]!;
        final value = _getScoreForAspect(aspect, scores);
        if (value > 0) {
          total += value;
          count++;
        }
      }
      
      classAverages[aspectName] = count > 0 ? total / count : 0.0;
    }
    
    String? weakestAspect;
    double lowestScore = 5.0;
    
    classAverages.forEach((aspect, score) {
      if (score < lowestScore) {
        lowestScore = score;
        weakestAspect = aspect;
      }
    });

    return [
      'Kelas menunjukkan variasi dalam pengembangan soft skills. Perlu perhatian khusus pada aspek yang masih lemah.',
      'Aspek terlemah: ${weakestAspect ?? 'Tidak dapat ditentukan'}',
      'Berikan perhatian khusus pada aspek yang lemah',
      'Lakukan pendekatan pembelajaran yang lebih interaktif',
      'Berikan umpan balik yang konstruktif secara berkala',
      'Lakukan kegiatan kelompok yang fokus pada aspek lemah',
      'Berikan proyek yang menantang untuk mengembangkan soft skills',
      'Lakukan evaluasi berkala untuk memantau perkembangan'
    ];
  }
}

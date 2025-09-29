import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/observer_data.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simpan data penilaian ke Firestore
  static Future<void> saveAssessmentData({
    required ObserverData observerData,
    required String instrumentType,
    required String classLevel,
    required String programKeahlian,
    required List<String> students,
    required Map<String, Map<String, String>> answers,
    required Map<String, Map<String, double>> studentScores,
  }) async {
    try {
      // Ambil email user yang sedang login
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email ?? 'unknown@example.com';
      final userUid = currentUser?.uid ?? 'unknown_uid';

      // Buat document ID dengan timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final docId = 'assessment_${timestamp}';

      // Data yang akan disimpan
      final assessmentData = {
        'id': docId,
        'timestamp': FieldValue.serverTimestamp(),
        'user': {
          'uid': userUid,
          'email': userEmail,
        },
        'observer': {
          'name': observerData.observerName,
          'school': observerData.schoolName,
          'mitra': observerData.mitraName,
          'role': observerData.role,
        },
        'assessment': {
          'instrumentType': instrumentType,
          'classLevel': classLevel,
          'programKeahlian': programKeahlian,
          'students': students,
        },
        'answers': answers,
        'scores': studentScores,
        'summary': _calculateSummary(studentScores),
      };

      // Simpan ke collection 'assessments'
      await _firestore
          .collection('assessments')
          .doc(docId)
          .set(assessmentData);

      print('✅ Data berhasil disimpan ke Firebase dengan ID: $docId');
    } catch (e) {
      print('❌ Error menyimpan data ke Firebase: $e');
      rethrow;
    }
  }

  // Ambil semua data penilaian
  static Future<List<Map<String, dynamic>>> getAllAssessments() async {
    try {
      final querySnapshot = await _firestore
          .collection('assessments')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error mengambil data dari Firebase: $e');
      return [];
    }
  }

  // Ambil data penilaian berdasarkan ID
  static Future<Map<String, dynamic>?> getAssessmentById(String id) async {
    try {
      final doc = await _firestore.collection('assessments').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error mengambil data dari Firebase: $e');
      return null;
    }
  }

  // Hapus data penilaian
  static Future<void> deleteAssessment(String id) async {
    try {
      await _firestore.collection('assessments').doc(id).delete();
      print('✅ Data berhasil dihapus dari Firebase');
    } catch (e) {
      print('❌ Error menghapus data dari Firebase: $e');
      rethrow;
    }
  }

  // Simpan data user Google ke Firestore
  static Future<void> saveGoogleUserData({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      // Ambil nama dari email (sebelum @)
      final emailName = _extractNameFromEmail(email);
      final finalDisplayName = displayName.isNotEmpty ? displayName : emailName;

      final userData = {
        'uid': uid,
        'email': email,
        'displayName': finalDisplayName,
        'photoURL': photoURL,
        'provider': 'google',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Simpan ke collection 'users' dengan document ID = uid
      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      print('✅ Data user Google berhasil disimpan ke Firestore dengan UID: $uid');
    } catch (e) {
      print('❌ Error menyimpan data user Google ke Firestore: $e');
      rethrow;
    }
  }

  // Fungsi untuk mengambil nama dari email (sebelum @)
  static String _extractNameFromEmail(String email) {
    try {
      final parts = email.split('@');
      if (parts.isNotEmpty) {
        String name = parts[0];
        // Hapus angka dan karakter khusus, ganti dengan spasi
        name = name.replaceAll(RegExp(r'[0-9._-]'), ' ');
        // Hapus spasi berlebih dan kapitalisasi huruf pertama
        name = name.trim().split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : ''
        ).join(' ');
        return name.isNotEmpty ? name : 'User';
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  // Ambil data user berdasarkan UID
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error mengambil data user dari Firestore: $e');
      return null;
    }
  }

  // Simpan data user dari Firebase Auth (untuk email/password dan phone)
  static Future<void> saveUserData({
    required String uid,
    required String email,
    String? displayName,
    String? phoneNumber,
    String provider = 'email',
  }) async {
    try {
      // Ambil nama dari email jika displayName kosong
      final emailName = _extractNameFromEmail(email);
      final finalDisplayName = displayName?.isNotEmpty == true ? displayName : emailName;

      final userData = {
        'uid': uid,
        'email': email,
        'displayName': finalDisplayName,
        'phoneNumber': phoneNumber,
        'provider': provider,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Simpan ke collection 'users' dengan document ID = uid
      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      print('✅ Data user berhasil disimpan ke Firestore dengan UID: $uid');
    } catch (e) {
      print('❌ Error menyimpan data user ke Firestore: $e');
      rethrow;
    }
  }

  // Hitung summary statistik
  static Map<String, dynamic> _calculateSummary(Map<String, Map<String, double>> studentScores) {
    final allScores = <double>[];
    final skillAverages = <String, double>{};

    // Kumpulkan semua skor
    studentScores.forEach((student, scores) {
      scores.forEach((skill, score) {
        allScores.add(score);
        skillAverages[skill] = (skillAverages[skill] ?? 0) + score;
      });
    });

    // Hitung rata-rata per skill
    final studentCount = studentScores.length;
    skillAverages.forEach((skill, total) {
      skillAverages[skill] = total / studentCount;
    });

    // Hitung statistik umum
    final averageScore = allScores.isNotEmpty 
        ? allScores.reduce((a, b) => a + b) / allScores.length 
        : 0.0;

    return {
      'totalStudents': studentCount,
      'averageScore': averageScore,
      'skillAverages': skillAverages,
      'totalAssessments': allScores.length,
    };
  }
}

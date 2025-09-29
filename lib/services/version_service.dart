import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VersionService {
  static String? _version;
  static String? _minimumVersion;
  
  static Future<String> getVersion() async {
    if (_version != null) return _version!;
    
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
      return _version ?? '1.0.0';
    } catch (e) {
      return '1.0.0';
    }
  }
  
  // Ambil minimum version dari Firestore
  static Future<String?> getMinimumVersionFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('validate_version')
          .doc('versionName')
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _minimumVersion = data['minimum'] as String?;
        
        // Print versionName dari Firestore untuk debugging
        print('📱 Version dari Firestore: $_minimumVersion');
        
        return _minimumVersion;
      } else {
        print('⚠️ Document versionName tidak ditemukan di Firestore');
        return null;
      }
    } catch (e) {
      print('❌ Error mengambil minimum version dari Firestore: $e');
      return null;
    }
  }
  
  // Validasi apakah versi aplikasi memenuhi minimum requirement
  static Future<bool> validateVersion() async {
    try {
      // Ambil versi aplikasi saat ini
      final currentVersion = await getVersion();
      print('📱 Versi aplikasi saat ini: $currentVersion');
      
      // Ambil minimum version dari Firestore
      final minimumVersion = await getMinimumVersionFromFirestore();
      
      if (minimumVersion == null) {
        print('⚠️ Tidak dapat mengambil minimum version, mengizinkan aplikasi berjalan');
        return true; // Jika tidak bisa ambil dari Firestore, izinkan aplikasi berjalan
      }
      
      // Bandingkan versi
      final isValid = _compareVersions(currentVersion, minimumVersion);
      
      if (isValid) {
        print('✅ Versi aplikasi valid: $currentVersion >= $minimumVersion');
      } else {
        print('❌ Versi aplikasi tidak valid: $currentVersion < $minimumVersion');
        print('🚫 Aplikasi tidak diizinkan berjalan');
      }
      
      return isValid;
    } catch (e) {
      print('❌ Error validasi versi: $e');
      return true; // Jika error, izinkan aplikasi berjalan
    }
  }
  
  // Bandingkan dua versi (format: x.y.z)
  static bool _compareVersions(String currentVersion, String minimumVersion) {
    try {
      final current = _parseVersion(currentVersion);
      final minimum = _parseVersion(minimumVersion);
      
      for (int i = 0; i < 3; i++) {
        if (current[i] > minimum[i]) {
          return true;
        } else if (current[i] < minimum[i]) {
          return false;
        }
      }
      
      return true; // Versi sama
    } catch (e) {
      print('❌ Error parsing versi: $e');
      return true; // Jika error parsing, izinkan aplikasi berjalan
    }
  }
  
  // Parse versi string menjadi array integer [major, minor, patch]
  static List<int> _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length < 3) {
      throw Exception('Format versi tidak valid: $version');
    }
    
    return [
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    ];
  }
  
  // Method untuk clear cache jika diperlukan
  static void clearCache() {
    _version = null;
    _minimumVersion = null;
  }
}

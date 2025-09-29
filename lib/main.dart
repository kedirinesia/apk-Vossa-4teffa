import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/auth_wrapper.dart';
import 'pages/cover_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/otp_verification_page.dart';
import 'pages/observer_form_page.dart';
import 'pages/Instrument_selection_page.dart';
import 'pages/student_form_page.dart';
import 'pages/assessment_page.dart';
import 'pages/result_page.dart';
import 'pages/student_detail_page.dart';
import 'services/version_service.dart';
 
import 'models/observer_data.dart';
import 'models/student.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SoftSkillsApp());
}

class SoftSkillsApp extends StatelessWidget {
  const SoftSkillsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Penilaian Soft Skills TeFa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VersionValidationWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/observerForm': (context) => const ObserverFormPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/otp-verification':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                verificationId: args['verificationId'] as String,
                phoneNumber: args['phoneNumber'] as String,
              ),
            );
          case '/instrumentSelection':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => InstrumentSelectionPage(
                observerData: args['observerData'] as ObserverData,
              ),
            );
          case '/studentForm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StudentFormPage(
                observerData: args['observerData'] as ObserverData,
                instrumentType: args['instrumentType'] as String,
              ),
            );
          case '/assessment':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AssessmentPage(
                students: args['students'] as List<String>,
                instrumentType: args['instrumentType'] as String,
                classLevel: args['classLevel'] as String,
                programKeahlian: args['programKeahlian'] as String,
                observerData: args['observerData'] as ObserverData,
              ),
            );
          case '/result':
            final args = settings.arguments as Map<String, dynamic>;
            final studentNames = args['students'] as List<String>;
            final students = studentNames.map((name) => Student(name: name)).toList();
            return MaterialPageRoute(
              builder: (context) => ResultPage(
                students: students,
                observerData: args['observerData'] as ObserverData?,
                studentScores: args['studentScores'] as Map<String, Map<String, double>>,
                answers: args['answers'] as Map<String, Map<String, String>>,
                classLevel: args['classLevel'] as String?,
                programKeahlian: args['programKeahlian'] as String?,
              ),
            );
          case '/student-detail':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => StudentDetailPage(
                studentName: args['studentName'] as String,
                studentScores: args['studentScores'] as Map<String, double>,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const CoverPage(),
            );
        }
      },
    );
  }
}

// Widget wrapper untuk validasi versi
class VersionValidationWrapper extends StatefulWidget {
  const VersionValidationWrapper({super.key});

  @override
  State<VersionValidationWrapper> createState() => _VersionValidationWrapperState();
}

class _VersionValidationWrapperState extends State<VersionValidationWrapper> {
  bool _isValidating = true;
  bool _isVersionValid = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _validateVersion();
  }

  Future<void> _validateVersion() async {
    try {
      final isValid = await VersionService.validateVersion();
      
      setState(() {
        _isValidating = false;
        _isVersionValid = isValid;
        if (!isValid) {
          _errorMessage = 'Versi aplikasi Anda terlalu lama. Silakan update aplikasi ke versi terbaru.';
        }
      });
    } catch (e) {
      setState(() {
        _isValidating = false;
        _isVersionValid = false;
        _errorMessage = 'Terjadi kesalahan saat memvalidasi versi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Memvalidasi versi aplikasi...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isVersionValid) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Versi Aplikasi Tidak Didukung',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isValidating = true;
                    });
                    _validateVersion();
                  },
                  child: const Text('Coba Lagi'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Keluar dari aplikasi
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Keluar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Jika versi valid, tampilkan aplikasi normal
    return const AuthWrapper();
  }
}

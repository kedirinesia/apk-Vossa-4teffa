import 'package:flutter/material.dart';
import 'pages/cover_page.dart';
import 'pages/observer_form_page.dart';
import 'pages/instrument_selection_page.dart';
import 'pages/student_form_page.dart';
import 'pages/assessment_page.dart';
import 'models/observer_data.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soft Skills Assessment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const CoverPage(),
        '/observerForm': (context) => const ObserverFormPage(),
        '/instrumentSelection': (context) {
          final observerData = ModalRoute.of(context)!.settings.arguments as ObserverData;
          return InstrumentSelectionPage(observerData: observerData);
        },
        '/studentForm': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StudentFormPage(
            observerData: args['observerData'],
            instrumentType: args['instrumentType'],
          );
        },
        '/assessment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AssessmentPage(
            students: args['students'],
            instrumentType: args['instrumentType'],
            classLevel: args['classLevel'],
            programKeahlian: args['programKeahlian'],
            observerData: args['observerData'],
          );
        },
      },
    );
  }
}

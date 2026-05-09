import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tri_alert/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tri Alert',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tri Alert'),
        ),
        body: const Center(
          child: Text('Welcome to Tri Alert!'),
        ),
      ),
    );
  }
}
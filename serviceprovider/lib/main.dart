import 'package:flutter/material.dart';
import 'package:serviceprovider/screen/addskills.dart';
import 'package:serviceprovider/screen/landingpage.dart';
import 'package:serviceprovider/screen/spDashboardpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://awbbcyahdusjhmlryvef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3YmJjeWFoZHVzamhtbHJ5dmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxODgyNDEsImV4cCI6MjA1NDc2NDI0MX0.6Uf3OQIgz466L-14CuUTiGQYxVdgu2ZliCnNcoNDh5I',
  );

  runApp(MainApp());
}

// Get a reference to your Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final session = supabase.auth.currentSession;

    // Navigate to the appropriate screen based on the authentication state
    if (session != null) {
      return DashBoard(); // Replace with your home screen widget
    } else {
      return Mylanding(); // Replace with your auth page widget
    }
  }
}






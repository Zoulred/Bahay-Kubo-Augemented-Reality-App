import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ar_capstone2/services/ARAudioservice.dart';
import 'screen/ARLoginRegister.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeSupabase();

  runApp(const MyApp());
}

Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: 'https://rqvszmgiqeslwytcdchc.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxdnN6bWdpcWVzbHd5dGNkY2hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNDA5NzcsImV4cCI6MjA3NzkxNjk3N30.iF7R6tWvzgz7708xwpQQ7KAxYHSD2kWXSOPQH34cbOE',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAudio();
    _checkSupabaseConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _audioService.pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        if (!_audioService.isPlaying && !_audioService.isTTSActive) {
          _audioService.resumeBackgroundMusic();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        _audioService.pauseBackgroundMusic();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeAudio() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      await _audioService.playBackgroundMusic();
      await _audioService.setVolume(0.5);
    } catch (e) {
      print('❌ Audio initialization failed: $e');
    }
  }

  Future<void> _checkSupabaseConnection() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').select('count').limit(1);
      print('✅ Supabase connection test successful');
    } catch (e) {
      print('❌ Supabase connection test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahay Kubo Adventure',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const LoginRegisterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

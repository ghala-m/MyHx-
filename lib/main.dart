import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'utils/theme_provider.dart';
import 'utils/theme.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- استيراد جديد
import 'firebase_options.dart'; // <-- استيراد جديد

// --- *** تعديل الدالة الرئيسية لتكون async *** ---
void main() async {
  // التأكد من أن كل شيء جاهز قبل تشغيل التطبيق
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- *** تهيئة Firebase *** ---
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyHxApp(),
    ),
  );
}

class MyHxApp extends StatelessWidget {
  const MyHxApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'myhx-',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/meal_service.dart';
import 'services/group_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BulkingLabApp());
}

class BulkingLabApp extends StatelessWidget {
  const BulkingLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => MealService()),
        ChangeNotifierProvider(create: (_) => GroupService()),
      ],
      child: MaterialApp(
        title: 'Bulking Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          primaryColor: const Color(0xFFE8FF45),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE8FF45),
            secondary: Color(0xFFE8FF45),
            surface: Color(0xFF1A1A1A),
            background: Color(0xFF0F0F0F),
          ),
          textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

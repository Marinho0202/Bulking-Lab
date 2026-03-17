import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- ADICIONE ESTES DOIS IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// -----------------------------------

import 'services/auth_service.dart';
import 'services/meal_service.dart';
import 'services/group_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  // 1. Garante que os widgets do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INICIALIZA O FIREBASE (A mágica acontece aqui)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  await initializeDateFormatting('pt_BR');
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
            onBackground: Color(0xFF0F0F0F), // Corrigido 'background' para 'onBackground' ou apenas remova se não usar
          ),
          textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
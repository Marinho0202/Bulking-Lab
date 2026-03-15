import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD

// --- ADICIONE ESTES DOIS IMPORTS ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// -----------------------------------

=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
import 'services/auth_service.dart';
import 'services/meal_service.dart';
import 'services/group_service.dart';
import 'screens/splash_screen.dart';

void main() async {
<<<<<<< HEAD
  // 1. Garante que os widgets do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();

  // 2. INICIALIZA O FIREBASE (A mágica acontece aqui)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

=======
  WidgetsFlutterBinding.ensureInitialized();
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
<<<<<<< HEAD
  
=======
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
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
<<<<<<< HEAD
            onBackground: Color(0xFF0F0F0F), // Corrigido 'background' para 'onBackground' ou apenas remova se não usar
=======
            background: Color(0xFF0F0F0F),
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
          ),
          textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae

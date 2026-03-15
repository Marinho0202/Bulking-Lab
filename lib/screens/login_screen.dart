import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showPass = false;

  Future<void> _login() async {
  setState(() {
    _loading = true;
    _error = null;
  });
  try {
    final ok = await context.read<AuthService>().login(
      _email.text.trim(),
      _password.text,
    );
    
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  } catch (e) {
    debugPrint("ERRO NO LOGIN: $e");
    setState(() {
      // Aqui tratamos o erro para o carregamento parar
      if (e.toString().contains('user-not-found')) {
        _error = "Usuário não encontrado. Verifique o e-mail ou cadastre-se.";
      } else if (e.toString().contains('wrong-password')) {
        _error = "Senha incorreta.";
      } else {
        _error = "Erro ao entrar: ${e.toString()}";
      }
      _loading = false; // PARA O CARREGAMENTO
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text('BL', style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.bg))),
              ),
              const SizedBox(height: 24),
              Text('Bem-vindo\nde volta!', style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2)),
              const SizedBox(height: 8),
              Text('Faça login para continuar sua jornada', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 40),
              BLTextField(label: 'E-mail', controller: _email, keyboardType: TextInputType.emailAddress, hint: 'seu@email.com'),
              const SizedBox(height: 16),
              BLTextField(
                label: 'Senha',
                controller: _password,
                obscure: !_showPass,
                hint: '••••••••',
                suffix: IconButton(
                  icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                  onPressed: () => setState(() => _showPass = !_showPass),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 32),
              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : BLButton(label: 'Entrar', onTap: _login),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Não tem conta?  ', style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: Text('Criar conta', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

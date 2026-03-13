import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();
  final _age = TextEditingController();
  String _gender = 'male';
  String _activity = 'moderate';
  String _goal = 'maintain';
  int _meals = 3;
  bool _loading = false;
  String? _error;
  int _step = 0;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ok = await context.read<AuthService>().register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        weight: double.parse(_weight.text),
        height: double.parse(_height.text),
        age: int.parse(_age.text),
        gender: _gender,
        activityLevel: _activity,
        goal: _goal,
        mealsPerDay: _meals,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false);
      } else {
        setState(() => _error = 'E-mail já cadastrado.');
      }
    } catch (e) {
      setState(() => _error = 'Verifique os dados e tente novamente.');
    }
    setState(() => _loading = false);
  }

  Widget _buildStep0() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepTitle('Dados da conta'),
      BLTextField(label: 'Nome completo', controller: _name, hint: 'Seu nome'),
      const SizedBox(height: 16),
      BLTextField(label: 'E-mail', controller: _email, keyboardType: TextInputType.emailAddress, hint: 'seu@email.com'),
      const SizedBox(height: 16),
      BLTextField(label: 'Senha', controller: _password, obscure: true, hint: '••••••••'),
    ],
  );

  Widget _buildStep1() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepTitle('Dados corporais'),
      Row(children: [
        Expanded(child: BLTextField(label: 'Peso (kg)', controller: _weight, keyboardType: TextInputType.number, hint: '70')),
        const SizedBox(width: 12),
        Expanded(child: BLTextField(label: 'Altura (cm)', controller: _height, keyboardType: TextInputType.number, hint: '175')),
      ]),
      const SizedBox(height: 16),
      BLTextField(label: 'Idade', controller: _age, keyboardType: TextInputType.number, hint: '25'),
      const SizedBox(height: 16),
      _label('Sexo'),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _selectBtn('Masculino', _gender == 'male', () => setState(() => _gender = 'male'))),
        const SizedBox(width: 12),
        Expanded(child: _selectBtn('Feminino', _gender == 'female', () => setState(() => _gender = 'female'))),
      ]),
    ],
  );

  Widget _buildStep2() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepTitle('Objetivos'),
      _label('Nível de atividade'),
      const SizedBox(height: 8),
      ...AppText.activityLabels.entries.map((e) =>
        _radioTile(e.value, _activity == e.key, () => setState(() => _activity = e.key)),
      ),
      const SizedBox(height: 16),
      _label('Objetivo'),
      const SizedBox(height: 8),
      ...AppText.goalLabels.entries.map((e) =>
        _radioTile(e.value, _goal == e.key, () => setState(() => _goal = e.key)),
      ),
      const SizedBox(height: 16),
      _label('Refeições por dia'),
      const SizedBox(height: 8),
      Row(children: [
        for (int i = 2; i <= 6; i++) ...[
          Expanded(child: _selectBtn('$i', _meals == i, () => setState(() => _meals = i))),
          if (i < 6) const SizedBox(width: 8),
        ]
      ]),
    ],
  );

  Widget _stepTitle(String t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(t, style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 20),
    ],
  );

  Widget _label(String t) => Text(t, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500));

  Widget _selectBtn(String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label, style: TextStyle(
          color: selected ? AppColors.bg : AppColors.textSecondary,
          fontWeight: FontWeight.w600, fontSize: 13,
        )),
      ),
    ),
  );

  Widget _radioTile(String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: selected ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(children: [
        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? AppColors.primary : AppColors.textMuted, size: 18),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary, fontSize: 14)),
      ]),
    ),
  );

  bool _canAdvance() {
    if (_step == 0) return _name.text.isNotEmpty && _email.text.isNotEmpty && _password.text.length >= 6;
    if (_step == 1) return _weight.text.isNotEmpty && _height.text.isNotEmpty && _age.text.isNotEmpty;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Row(
          children: List.generate(3, (i) => Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i <= _step ? AppColors.primary : AppColors.surface2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == 0) _buildStep0(),
              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
              ],
              const SizedBox(height: 32),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else if (_step < 2)
                BLButton(label: 'Continuar', onTap: _canAdvance() ? () => setState(() => _step++) : null)
              else
                BLButton(label: 'Criar conta', onTap: _register),
            ],
          ),
        ),
      ),
    );
  }
}

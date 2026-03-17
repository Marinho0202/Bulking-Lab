import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _name;
  late TextEditingController _weight;
  late TextEditingController _height;
  late TextEditingController _age;
  late TextEditingController _newPassword;

  late String _gender;
  late String _activity;
  late String _goal;
  late int _meals;

  bool _loading = false;
  bool _showPassword = false;
  bool _uploadingPhoto = false;
  String? _error;
  String? _success;
  File? _photoFile; // foto selecionada localmente (antes do upload)

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser!;
    _name = TextEditingController(text: user.name);
    _weight = TextEditingController(text: user.weight.toString());
    _height = TextEditingController(text: user.height.toString());
    _age = TextEditingController(text: user.age.toString());
    _newPassword = TextEditingController();
    _gender = user.gender;
    _activity = user.activityLevel;
    _goal = user.goal;
    _meals = user.mealsPerDay;
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _age.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() { _uploadingPhoto = true; _error = null; });
    try {
      final user = context.read<AuthService>().currentUser!;
      final file = File(picked.path);
      final ext = picked.path.split('.').last.toLowerCase();
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.id}.$ext');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'photoUrl': url});

      await context.read<AuthService>().reloadUser();

      if (mounted) {
        setState(() {
          _photoFile = file;
          _success = 'Foto atualizada!';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Erro ao enviar foto: $e');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser!;
      final db = FirebaseFirestore.instance;

      final double weight = double.parse(_weight.text.replaceAll(',', '.'));
      final double height = double.parse(_height.text.replaceAll(',', '.'));
      final int age = int.parse(_age.text);

      // Atualiza dados no Firestore
      await db.collection('users').doc(user.id).update({
        'name': _name.text.trim(),
        'weight': weight,
        'height': height,
        'age': age,
        'gender': _gender,
        'activityLevel': _activity,
        'goal': _goal,
        'mealsPerDay': _meals,
        'currentWeight': weight,
      });

      // Atualiza senha no Firebase Auth se o campo estiver preenchido
      if (_newPassword.text.isNotEmpty) {
        if (_newPassword.text.length < 6) {
          setState(() {
            _error = 'A senha deve ter pelo menos 6 caracteres.';
            _loading = false;
          });
          return;
        }
        await FirebaseAuth.instance.currentUser?.updatePassword(_newPassword.text);
      }

      // Recarrega os dados do usuário no AuthService
      await authService.reloadUser();

      if (!mounted) return;
      setState(() {
        _success = 'Perfil atualizado com sucesso!';
        _newPassword.clear();
      });
    } catch (e) {
      setState(() => _error = 'Erro ao salvar: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      );

  Widget _selectBtn(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  color: selected ? AppColors.bg : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ),
        ),
      );

  Widget _radioTile(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border:
                selected ? Border.all(color: AppColors.primary, width: 1.5) : null,
          ),
          child: Row(children: [
            Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textMuted,
                size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    fontSize: 14)),
          ]),
        ),
      );

  Widget _sectionTitle(String title, IconData icon) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 16),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final initials =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Editar Perfil',
            style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Column(children: [
    GestureDetector(
                  onTap: _uploadingPhoto ? null : _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: _photoFile != null
                              ? Image.file(_photoFile!, fit: BoxFit.cover)
                              : (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                                  ? Image.network(user.photoUrl!, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(initials,
                                            style: GoogleFonts.inter(fontSize: 32,
                                                fontWeight: FontWeight.w800, color: AppColors.bg)),
                                      ))
                                  : Center(
                                      child: Text(initials,
                                          style: GoogleFonts.inter(fontSize: 32,
                                              fontWeight: FontWeight.w800, color: AppColors.bg)),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _uploadingPhoto ? AppColors.surface2 : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.bg, width: 2),
                          ),
                          child: _uploadingPhoto
                              ? const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: AppColors.primary),
                                )
                              : const Icon(Icons.camera_alt_outlined,
                                  color: AppColors.primary, size: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.email,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ]),
            ),

            // ── Dados pessoais ──────────────────────────────────────
            _sectionTitle('Dados pessoais', Icons.person_outline),

            BLTextField(
                label: 'Nome completo',
                controller: _name,
                hint: 'Seu nome'),
            const SizedBox(height: 16),

            _label('Sexo'),
            Row(children: [
              Expanded(
                  child: _selectBtn('Masculino', _gender == 'male',
                      () => setState(() => _gender = 'male'))),
              const SizedBox(width: 12),
              Expanded(
                  child: _selectBtn('Feminino', _gender == 'female',
                      () => setState(() => _gender = 'female'))),
            ]),

            // ── Dados corporais ──────────────────────────────────────
            _sectionTitle('Dados corporais', Icons.monitor_weight_outlined),

            Row(children: [
              Expanded(
                  child: BLTextField(
                      label: 'Peso (kg)',
                      controller: _weight,
                      keyboardType: TextInputType.number,
                      hint: '70')),
              const SizedBox(width: 12),
              Expanded(
                  child: BLTextField(
                      label: 'Altura (cm)',
                      controller: _height,
                      keyboardType: TextInputType.number,
                      hint: '175')),
            ]),
            const SizedBox(height: 16),
            BLTextField(
                label: 'Idade',
                controller: _age,
                keyboardType: TextInputType.number,
                hint: '25'),

            // ── Objetivos ────────────────────────────────────────────
            _sectionTitle('Objetivos', Icons.flag_outlined),

            _label('Nível de atividade'),
            ...AppText.activityLabels.entries.map((e) => _radioTile(
                e.value,
                _activity == e.key,
                () => setState(() => _activity = e.key))),
            const SizedBox(height: 16),

            _label('Objetivo'),
            ...AppText.goalLabels.entries.map((e) => _radioTile(
                e.value,
                _goal == e.key,
                () => setState(() => _goal = e.key))),
            const SizedBox(height: 16),

            _label('Refeições por dia'),
            Row(children: [
              for (int i = 2; i <= 6; i++) ...[
                Expanded(
                    child: _selectBtn('$i', _meals == i,
                        () => setState(() => _meals = i))),
                if (i < 6) const SizedBox(width: 8),
              ]
            ]),

            // ── Segurança ────────────────────────────────────────────
            _sectionTitle('Segurança', Icons.lock_outline),

            // Campo de nova senha
            TextField(
              controller: _newPassword,
              obscureText: !_showPassword,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nova senha',
                labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                hintText: 'Deixe em branco para manter a atual',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 18),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),

            // ── Feedback ─────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13))),
                ]),
              ),
            ],
            if (_success != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_success!,
                          style: const TextStyle(
                              color: AppColors.success, fontSize: 13))),
                ]),
              ),
            ],

            const SizedBox(height: 32),
            _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : BLButton(label: 'Salvar alterações', onTap: _save),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _initialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;

  AuthService() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _fetchUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
      }
      _initialized = true;
      notifyListeners();
    });
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados: $e");
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
    required int mealsPerDay,
  }) async {
    try {
      // 1. Cria no Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          id: credential.user!.uid,
          name: name,
          email: email,
          weight: weight,
          height: height,
          age: age,
          gender: gender,
          activityLevel: activityLevel,
          goal: goal,
          mealsPerDay: mealsPerDay,
        );

        // 2. Tenta salvar no Firestore
        try {
          await _db.collection('users').doc(user.id).set(user.toJson());
          _currentUser = user;
          notifyListeners();
          return true;
        } catch (firestoreError) {
          // Se o Firestore falhar (regras bloqueadas), deletamos o user do Auth
          // para você conseguir tentar cadastrar o mesmo e-mail de novo depois de corrigir as regras.
          await credential.user!.delete();
          debugPrint("ERRO NO FIRESTORE: $firestoreError");
          rethrow; // Envia o erro para a tela
        }
      }
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint("ERRO NO AUTH: ${e.code}");
      rethrow;
    } catch (e) {
      debugPrint("ERRO DESCONHECIDO: $e");
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _fetchUserData(credential.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateWeight(double newWeight) async {
    if (_currentUser == null) return;
    try {
      await _db.collection('users').doc(_currentUser!.id).update({
        'weight': newWeight,
      });
      _currentUser!.currentWeight = newWeight;
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao atualizar peso: $e");
    }
  }
}
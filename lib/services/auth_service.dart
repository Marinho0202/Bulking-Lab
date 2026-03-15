<<<<<<< HEAD
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _initialized = false;
=======
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _initialized = false;
  final _uuid = const Uuid();
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;

  AuthService() {
<<<<<<< HEAD
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
=======
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('current_user');
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(json.decode(userData));
      } catch (_) {}
    }
    _initialized = true;
    notifyListeners();
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
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
<<<<<<< HEAD
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
=======
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString('all_users') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersRaw);

      if (users.containsKey(email)) return false;

      final user = UserModel(
        id: _uuid.v4(),
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

      final userJson = user.toJson();
      userJson['password'] = password;
      users[email] = userJson;

      await prefs.setString('all_users', json.encode(users));
      await _saveCurrentUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
    }
  }

  Future<bool> login(String email, String password) async {
    try {
<<<<<<< HEAD
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
=======
      final prefs = await SharedPreferences.getInstance();
      final usersRaw = prefs.getString('all_users') ?? '{}';
      final Map<String, dynamic> users = json.decode(usersRaw);

      if (!users.containsKey(email)) return false;
      final userData = users[email] as Map<String, dynamic>;
      if (userData['password'] != password) return false;

      final user = UserModel.fromJson(userData);
      await _saveCurrentUser(user);
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
    }
  }

  Future<void> logout() async {
<<<<<<< HEAD
    await _auth.signOut();
=======
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae
    _currentUser = null;
    notifyListeners();
  }

<<<<<<< HEAD
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
=======
  Future<void> _saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
  }

  Future<void> updateWeight(double newWeight) async {
    if (_currentUser == null) return;
    _currentUser!.currentWeight = newWeight;
    await _saveCurrentUser(_currentUser!);
    notifyListeners();
  }
}
>>>>>>> 223706ce7b345145af6e7cc688b6e65577f8ddae

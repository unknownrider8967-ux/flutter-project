import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:syncsphere/data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('current_user_id');
    if (userId == null) return false;

    final usersJson = prefs.getString('users') ?? '[]';
    final users = (jsonDecode(usersJson) as List)
        .map((u) => AppUser.fromMap(u as Map<String, dynamic>))
        .toList();

    try {
      _user = users.firstWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final rawList = jsonDecode(usersJson) as List;
      final hash = _hashPassword(password);

      for (final u in rawList) {
        final map = u as Map<String, dynamic>;
        if (map['email'] == email && map['passwordHash'] == hash) {
          _user = AppUser.fromMap(map);
          await prefs.setString('current_user_id', _user!.id);
          _setLoading(false);
          return true;
        }
      }
      _setLoading(false);
      return false;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('users') ?? '[]';
      final rawList = jsonDecode(usersJson) as List;

      // Check duplicate email
      for (final u in rawList) {
        if ((u as Map<String, dynamic>)['email'] == email) {
          _setLoading(false);
          return false;
        }
      }

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final userMap = {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': _hashPassword(password),
      };

      rawList.add(userMap);
      await prefs.setString('users', jsonEncode(rawList));
      _user = AppUser(id: id, name: name, email: email);
      await prefs.setString('current_user_id', id);
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  /// Demo sign-in: creates/reuses a guest account.
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      const demoEmail = 'demo@syncsphere.app';
      const demoId = 'demo-google-user';
      const demoName = 'Demo User';

      final usersJson = prefs.getString('users') ?? '[]';
      final rawList = jsonDecode(usersJson) as List;

      final exists = rawList.any(
          (u) => (u as Map<String, dynamic>)['id'] == demoId);

      if (!exists) {
        rawList.add({
          'id': demoId,
          'name': demoName,
          'email': demoEmail,
          'passwordHash': '',
        });
        await prefs.setString('users', jsonEncode(rawList));
      }

      _user = AppUser(id: demoId, name: demoName, email: demoEmail);
      await prefs.setString('current_user_id', demoId);
      _setLoading(false);
      return true;
    } catch (_) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    _user = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    // In a local-only app we just confirm the email exists.
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users') ?? '[]';
    final rawList = jsonDecode(usersJson) as List;
    return rawList
        .any((u) => (u as Map<String, dynamic>)['email'] == email);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

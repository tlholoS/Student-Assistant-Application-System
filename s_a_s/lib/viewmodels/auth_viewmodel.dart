/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUserData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUserData => _currentUserData;

  // Persistent login check
  Future<void> checkExistingSession() async {
    final user = _authService.currentUser;
    if (user != null) {
      await fetchUserData(user.id);
    }
  }

  Future<void> fetchUserData(String userId) async {
    _currentUserData = await _authService.getUserData(userId);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await _authService.login(email, password);
      
      if (response.user != null) {
        await fetchUserData(response.user!.id);
        _setLoading(false);
        return true; // Login successful
      }
    } catch (e) {
      _errorMessage = 'Invalid email or password.';
    }

    _setLoading(false);
    return false; // Login failed
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUserData = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.user != null) {
        await fetchUserData(response.user!.id);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _setLoading(false);
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
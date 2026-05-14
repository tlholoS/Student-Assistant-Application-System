/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:flutter/material.dart';
import '../services/db_service.dart';

class ApplicationDetailsViewModel extends ChangeNotifier {
  final DbService _dbService = DbService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> updateApplication({
    required String applicationId,
    required int yearOfStudy,
    required String academicLevel,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _dbService.updateApplication(
        applicationId: applicationId,
        yearOfStudy: yearOfStudy,
        academicLevel: academicLevel,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update application: $e';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _dbService.deleteApplication(applicationId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application: $e';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

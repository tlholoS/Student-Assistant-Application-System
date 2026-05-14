/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/
import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/db_service.dart';

class StudentViewModel extends ChangeNotifier {
  final DbService _dbService = DbService();

  bool _isLoading = false;
  String? _errorMessage;
  List<ApplicationModel> _myApplications = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ApplicationModel> get myApplications => _myApplications;

  // Helper to check if the list is empty
  bool get isEmpty => _myApplications.isEmpty;

  Future<void> fetchDashboardData(String studentId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _myApplications = await _dbService.fetchMyApplications(studentId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

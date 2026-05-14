/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/module_model.dart';
import '../services/db_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class ApplicationFormViewModel extends ChangeNotifier {
  final DbService _dbService = DbService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form Fields
  String _yearOfStudy = '';
  String get yearOfStudy => _yearOfStudy;

  String _academicLevel = 'Diploma';
  String get academicLevel => _academicLevel;
  final List<String> academicLevels = ['Diploma', 'Advanced Diploma', 'Degree', 'Honours', 'Masters'];

  ModuleModel? _selectedModule1;
  ModuleModel? get selectedModule1 => _selectedModule1;

  ModuleModel? _selectedModule2;
  ModuleModel? get selectedModule2 => _selectedModule2;

  File? _supportingDocument;
  File? get supportingDocument => _supportingDocument;
  String? _documentFileName;
  String? get documentFileName => _documentFileName;

  bool _isEligible = false;
  bool get isEligible => _isEligible;

  // Available modules to choose from
  List<ModuleModel> _availableModules = [];
  List<ModuleModel> get availableModules => _availableModules;

  ApplicationFormViewModel() {
    _loadModules();
  }

  Future<void> _loadModules() async {
    _isLoading = true;
    notifyListeners();
    try {
      _availableModules = await _dbService.fetchModules();
    } catch (e) {
      _errorMessage = "Failed to load modules: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setYearOfStudy(String year) {
    _yearOfStudy = year;
    notifyListeners();
  }

  void setAcademicLevel(String level) {
    _academicLevel = level;
    notifyListeners();
  }

  void setModule1(ModuleModel? module) {
    _selectedModule1 = module;
    // Prevent duplicate selections
    if (_selectedModule1?.id == _selectedModule2?.id) {
      _selectedModule2 = null;
    }
    notifyListeners();
  }

  void setModule2(ModuleModel? module) {
    _selectedModule2 = module;
    // Prevent duplicate selections
    if (_selectedModule2?.id == _selectedModule1?.id) {
      _selectedModule1 = null;
    }
    notifyListeners();
  }

  void toggleEligibility(bool? value) {
    _isEligible = value ?? false;
    notifyListeners();
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      _supportingDocument = File(result.files.single.path!);
      _documentFileName = result.files.single.name;
      notifyListeners();
    }
  }

  void removeDocument() {
    _supportingDocument = null;
    _documentFileName = null;
    notifyListeners();
  }

  bool _validateForm() {
    if (_yearOfStudy.isEmpty) {
      _errorMessage = 'Please enter your current year of study.';
      return false;
    }
    if (_selectedModule1 == null && _selectedModule2 == null) {
      _errorMessage = 'Please select at least one module.';
      return false;
    }
    if (_supportingDocument == null) {
      _errorMessage = 'Please upload your supporting documents (e.g., CV/Academic Record).';
      return false;
    }
    if (!_isEligible) {
      _errorMessage = 'You must confirm that you meet the eligibility criteria.';
      return false;
    }
    return true;
  }

  Future<bool> submitApplication(UserModel student) async {
    if (!_validateForm()) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload the supporting document
      final documentUrl = await _storageService.uploadDocument(
        _supportingDocument!,
        student.id,
      );

      // 2. Submit application for Module 1 (if selected)
      if (_selectedModule1 != null) {
        await _dbService.createApplication(
          studentId: student.id,
          moduleId: _selectedModule1!.id,
          yearOfStudy: _yearOfStudy,
          academicLevel: _academicLevel,
          documentUrl: documentUrl,
        );
      }

      // 3. Submit application for Module 2 (if selected)
      if (_selectedModule2 != null) {
        await _dbService.createApplication(
          studentId: student.id,
          moduleId: _selectedModule2!.id,
          yearOfStudy: _yearOfStudy,
          academicLevel: _academicLevel,
          documentUrl: documentUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
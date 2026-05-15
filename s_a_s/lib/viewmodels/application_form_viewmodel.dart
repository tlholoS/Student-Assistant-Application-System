/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/application_model.dart';
import '../models/module_model.dart';
import '../services/db_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
class ApplicationFormViewModel extends ChangeNotifier {
final DbService _dbService = DbService();
final StorageService _storageService = StorageService();
bool _isLoading = false;
bool get isLoading => _isLoading;
bool _isPickingFile = false;
bool get isPickingFile => _isPickingFile;
String? _errorMessage;
String? get errorMessage => _errorMessage;
String? _modulesLoadError;
String? get modulesLoadError => _modulesLoadError;
// Form Fields
String _yearOfStudy = '';
String get yearOfStudy => _yearOfStudy;
String _academicLevel = 'Diploma';
String get academicLevel => _academicLevel;
final List<String> academicLevels = ['Diploma', 'Advanced Diploma', 'Degree', 'Honours',
'Masters'];
ModuleModel? _selectedModule1;
ModuleModel? get selectedModule1 => _selectedModule1;
ModuleModel? _selectedModule2;
ModuleModel? get selectedModule2 => _selectedModule2;
File? _supportingDocument;
File? get supportingDocument => _supportingDocument;
Uint8List? _documentBytes;
Uint8List? get documentBytes => _documentBytes;
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
_modulesLoadError = null;
notifyListeners();
try {
_availableModules = await _dbService.fetchModules();
if (_availableModules.isEmpty) {
_modulesLoadError = "No modules available at this time.";
}
} catch (e) {
_modulesLoadError = "Failed to load modules: $e";
print('Error loading modules: $e');
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
try {
FilePickerResult? result = await FilePicker.platform.pickFiles(
type: FileType.custom,
allowedExtensions: ['pdf', 'doc', 'docx'],
withData: true,
);
if (result != null) {
_isPickingFile = true;
_documentFileName = result.files.single.name;
_errorMessage = null;
notifyListeners();
if (kIsWeb) {
_documentBytes = result.files.single.bytes;
} else if (result.files.single.path != null) {
_supportingDocument = File(result.files.single.path!);
_documentBytes = result.files.single.bytes ?? await _supportingDocument!.readAsBytes();
} else if (result.files.single.bytes != null) {
_documentBytes = result.files.single.bytes;
}
if (_documentBytes == null) {
_errorMessage = "Failed to read file content.";
_documentFileName = null;
}
}
} catch (e) {
_errorMessage = "Error picking file: $e";
print('Error picking file: $e');
} finally {
_isPickingFile = false;
notifyListeners();
}
}
void removeDocument() {
_supportingDocument = null;
_documentBytes = null;
_documentFileName = null;
notifyListeners();
}
bool _validateForm() {
if (_yearOfStudy.trim().isEmpty) {
_errorMessage = 'Please enter your current year of study.';
return false;
}
if (_selectedModule1 == null && _selectedModule2 == null) {
_errorMessage = 'Please select at least one module.';
return false;
}
if (_documentBytes == null) {
_errorMessage = 'Please upload your supporting documents (CV/Academic Record).';
return false;
}
if (!_isEligible) {
_errorMessage = 'You must confirm the eligibility criteria.';
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
print('Starting application submission for student: ${student.id}');
// 1. Upload the supporting document
print('Uploading document: $_documentFileName');
final documentUrl = await _storageService.uploadDocument(
_documentBytes!,
_documentFileName!,
student.id,
);
if (documentUrl == null) {
throw Exception('Failed to get a valid URL for the uploaded document.');
}
print('Document uploaded successfully: $documentUrl');
// 2. Submit applications
final List<Future> submissions = [];
if (_selectedModule1 != null) {
print('Submitting for Module 1: ${_selectedModule1!.moduleCode}');
submissions.add(_dbService.createApplication(
studentId: student.id,
moduleId: _selectedModule1!.id,
yearOfStudy: _yearOfStudy,
academicLevel: _academicLevel,
documentUrl: documentUrl,
));
}
if (_selectedModule2 != null) {
print('Submitting for Module 2: ${_selectedModule2!.moduleCode}');
submissions.add(_dbService.createApplication(
studentId: student.id,
moduleId: _selectedModule2!.id,
yearOfStudy: _yearOfStudy,
academicLevel: _academicLevel,
documentUrl: documentUrl,
));
}
await Future.wait(submissions);
print('All applications submitted successfully');
_isLoading = false;
notifyListeners();
return true;
} catch (e) {
print('Submission error: $e');
_errorMessage = e.toString().replaceFirst('Exception: ', '');
_isLoading = false;
notifyListeners();
return false;
}
}
}
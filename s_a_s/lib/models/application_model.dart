/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L

*/

import 'module_model.dart';

class ApplicationModel {
  final String id;
  final String studentId;
  final int yearOfStudy;
  final String academicLevel;
  final String status;
  final String? documentUrl;
  final List<ModuleModel> selectedModules;
  final String? studentName;
  final String? studentEmail;

  ApplicationModel({
    required this.id,
    required this.studentId,
    required this.yearOfStudy,
    required this.academicLevel,
    required this.status,
    this.documentUrl,
    required this.selectedModules,
    this.studentName,
    this.studentEmail,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    var moduleList = json['modules'] as List? ?? [];
    List<ModuleModel> parsedModules = moduleList.map((m) => ModuleModel.fromJson(m)).toList();
    
    // Parse student details if joined
    String? name;
    String? email;
    if (json['student'] != null) {
      final studentData = json['student'];
      email = studentData['email'];
      final fName = studentData['first_name'] ?? '';
      final lName = studentData['last_name'] ?? '';
      name = '$fName $lName'.trim();
    } else if (json['users'] != null) { // Fallback if relationship alias is 'users'
      final studentData = json['users'];
      email = studentData['email'];
      final fName = studentData['first_name'] ?? '';
      final lName = studentData['last_name'] ?? '';
      name = '$fName $lName'.trim();
    }

    return ApplicationModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      yearOfStudy: json['year_of_study'] as int,
      academicLevel: json['academic_level'] as String,
      status: json['status'] as String,
      documentUrl: json['document_url'] as String?,
      selectedModules: parsedModules,
      studentName: name,
      studentEmail: email,
    );
  }
}
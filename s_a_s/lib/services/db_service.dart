/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module_model.dart';
import '../models/application_model.dart';

class DbService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // READ: Fetch all available modules
  Future<List<ModuleModel>> fetchModules() async {
    final response = await _supabase
        .from('modules')
        .select()
        .order('module_code');
    return response.map((json) => ModuleModel.fromJson(json)).toList();
  }

  // READ: Fetch applications for a specific student
  Future<List<ApplicationModel>> fetchMyApplications(String studentId) async {
    try {
      final response = await _supabase
          .from('applications')
          .select('''
            *,
            modules:application_modules(
              modules(*)
            )
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return response.map((json) {
        final modulesNested = json['modules'] as List;
        json['modules'] = modulesNested.map((m) => m['modules']).toList();
        return ApplicationModel.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error fetching applications: $e');
      throw Exception('Failed to load applications. Please try again.');
    }
  }

  // CREATE: Submit a new application
  Future<void> submitApplication({
    required String studentId,
    required String yearOfStudy,
    required String academicLevel,
    required String? documentUrl,
    required String moduleId,
  }) async {
    final appResponse = await _supabase
        .from('applications')
        .insert({
          'student_id': studentId,
          'year_of_study': int.tryParse(yearOfStudy) ?? 1,
          'academic_level': academicLevel,
          'document_url': documentUrl,
        })
        .select()
        .single();

    final newAppId = appResponse['id'];

    await _supabase.from('application_modules').insert({
      'application_id': newAppId,
      'module_id': moduleId,
    });
  }

  // CREATE: Create application method that matches the ApplicationFormViewModel signature
  Future<void> createApplication({
    required String studentId,
    required String moduleId,
    required String yearOfStudy,
    required String academicLevel,
    required String? documentUrl,
  }) async {
    return submitApplication(
      studentId: studentId,
      moduleId: moduleId,
      yearOfStudy: yearOfStudy,
      academicLevel: academicLevel,
      documentUrl: documentUrl,
    );
  }

  // DELETE: Delete a pending application
  Future<void> deleteApplication(String applicationId) async {
    await _supabase.from('applications').delete().eq('id', applicationId);
  }

  // UPDATE: Update an application
  Future<void> updateApplication({
    required String applicationId,
    required int yearOfStudy,
    required String academicLevel,
  }) async {
    await _supabase
        .from('applications')
        .update({'year_of_study': yearOfStudy, 'academic_level': academicLevel})
        .eq('id', applicationId);
  }
}

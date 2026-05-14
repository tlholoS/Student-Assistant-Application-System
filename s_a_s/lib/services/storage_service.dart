/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<String?> uploadDocument(File file, String studentId) async {
    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '${studentId}_${const Uuid().v4()}.$fileExtension';
      final path = 'applications/$fileName';

      await _supabase.storage.from('documents').upload(path, file);
      
      // Get the public URL to save in the database
      final publicUrl = _supabase.storage.from('documents').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Failed to upload document.');
    }
  }
}
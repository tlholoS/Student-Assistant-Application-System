/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
class StorageService {
final SupabaseClient _supabase = Supabase.instance.client;
Future<String?> uploadDocument(Uint8List bytes, String fileName, String studentId) async {
try {
print('StorageService: Uploading document $fileName for student $studentId');
final fileExtension = fileName.split('.').last;
final storedFileName = '${studentId}_${const Uuid().v4()}.$fileExtension';
final path = 'applications/$storedFileName';
print('StorageService: Path is $path');
await _supabase.storage.from('documents').uploadBinary(
path,
bytes,
);
print('StorageService: Upload successful, getting public URL');
// Get the public URL to save in the database
final publicUrl = _supabase.storage.from('documents').getPublicUrl(path);
print('StorageService: Public URL is $publicUrl');
return publicUrl;
} catch (e) {
print('StorageService: Error uploading file: $e');
if (e.toString().contains('404')) {
throw Exception('Storage bucket "documents" not found. Please create it in Supabase.');
}
throw Exception('Failed to upload document: ${e.toString()}');
}
}
}
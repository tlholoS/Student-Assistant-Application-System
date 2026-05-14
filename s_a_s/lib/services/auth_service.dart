/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Check if a user is currently logged in (Persistent Session)
  User? get currentUser => _supabase.auth.currentUser;

  // Stream to listen to auth changes (e.g., token expiration)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Login with Email and Password
  Future<AuthResponse> login(String email, String password) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  // Fetch custom user data (including role) from the public.users table
  Future<UserModel?> getUserData(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
          
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user data: $e');
      return null; // Return null if user data isn't found
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Sign Up with Email and Password
  Future<AuthResponse> signUp({
    required String email, 
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create the user profile in the public.users table
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'role': 'student', // New registrations are students by default
        });
      }
      
      return response;
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }
}
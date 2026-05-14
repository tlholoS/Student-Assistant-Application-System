/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';

class AdminViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ApplicationModel> get applications => _filteredApplications;

  String _searchQuery = '';
  String _statusFilter = 'All'; // 'All', 'Pending', 'Approved', 'Rejected'
  
  String get currentStatusFilter => _statusFilter;

  Future<void> fetchAllApplications() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      // Fetch all apps with module data and user data
      // Note: Relationship name depends on Supabase schema setup.
      // Usually it's 'users' if the table is users, or 'student:users'
      final response = await _supabase.from('applications').select('''
        *,
        users (email, first_name, last_name),
        modules:application_modules ( modules(*) )
      ''').order('created_at', ascending: false);

      _allApplications = response.map((json) {
        final modulesNested = json['modules'] as List? ?? [];
        json['modules'] = modulesNested.map((m) => m['modules']).toList();
        return ApplicationModel.fromJson(json);
      }).toList();
      
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Error fetching admin apps: $e';
    }
    _setLoading(false);
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredApplications = _allApplications.where((app) {
      final matchesStatus = _statusFilter == 'All' || app.status.toLowerCase() == _statusFilter.toLowerCase();
      
      final searchTarget = '${app.id} ${app.studentName ?? ''} ${app.studentEmail ?? ''} ${app.academicLevel}'.toLowerCase();
      final matchesQuery = _searchQuery.isEmpty || searchTarget.contains(_searchQuery);
                          
      return matchesStatus && matchesQuery;
    }).toList();
    notifyListeners();
  }

  Future<void> updateApplicationStatus(String applicationId, String newStatus) async {
    _setLoading(true);
    try {
      await _supabase.from('applications')
          .update({'status': newStatus})
          .eq('id', applicationId);
      await fetchAllApplications(); // Refresh list to get latest data
    } catch (e) {
      _errorMessage = 'Error updating status: $e';
      _setLoading(false);
    }
  }

  Future<void> deleteApplication(String applicationId) async {
    _setLoading(true);
    try {
      await _supabase.from('applications').delete().eq('id', applicationId);
      await fetchAllApplications();
    } catch(e) {
      _errorMessage = 'Error deleting application: $e';
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

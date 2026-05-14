/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../models/application_model.dart';
import '../../services/navigation_service.dart';
import '../../routes/route_constants.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/premium_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.currentUserData?.role != 'admin') {
        authVM.logout();
        NavigationService.clearStackAndNavigateTo(RouteConstants.login);
        return;
      }
      context.read<AdminViewModel>().fetchAllApplications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showActionDialog(BuildContext context, ApplicationModel app) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3192).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  color: Color(0xFF2E3192),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                app.studentName ?? 'Student',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                app.studentEmail ?? 'N/A',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),
              Text(
                'Review Application Status',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AdminViewModel>().updateApplicationStatus(
                          app.id,
                          'approved',
                        );
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AdminViewModel>().updateApplicationStatus(
                          app.id,
                          'rejected',
                        );
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.orange.shade600),
                        foregroundColor: Colors.orange.shade600,
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  context.read<AdminViewModel>().deleteApplication(app.id);
                  Navigator.pop(ctx);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                label: const Text(
                  'Remove Permanently',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: MeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(authVM, adminVM),
              Expanded(
                child: ResponsiveLayout(
                  child: Column(
                    children: [
                      _buildSummaryCards(adminVM),
                      _buildSearchAndFilter(adminVM),
                      Expanded(child: _buildApplicationList(adminVM)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AuthViewModel authVM, AdminViewModel adminVM) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Console',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Management',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => adminVM.fetchAllApplications(),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              authVM.logout();
              NavigationService.clearStackAndNavigateTo(RouteConstants.login);
            },
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AdminViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _statsCard(
            'Total',
            vm.applications.length.toString(),
            const Color(0xFF2E3192),
            Icons.all_inclusive_rounded,
          ),
          const SizedBox(width: 12),
          _statsCard(
            'Pending',
            vm.applications
                .where((a) => a.status == 'pending')
                .length
                .toString(),
            Colors.orange,
            Icons.pending_rounded,
          ),
          const SizedBox(width: 12),
          _statsCard(
            'Approved',
            vm.applications
                .where((a) => a.status == 'approved')
                .length
                .toString(),
            Colors.green,
            Icons.check_circle_rounded,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _statsCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(AdminViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => vm.setSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search by student name or email...',
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              fillColor: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Pending', 'Approved', 'Rejected'].map((
                status,
              ) {
                final isSelected = vm.currentStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) => vm.setStatusFilter(status),
                    selectedColor: const Color(0xFF2E3192),
                    labelStyle: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    elevation: isSelected ? 4 : 0,
                    shadowColor: const Color(0xFF2E3192).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildApplicationList(AdminViewModel vm) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    if (vm.applications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No matching applications',
              style: GoogleFonts.outfit(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: vm.applications.length,
      itemBuilder: (context, index) {
        final app = vm.applications[index];
        return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 20,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showActionDialog(context, app),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    app.studentName ?? 'Student',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusChip(status: app.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.studentEmail ?? 'No email',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.school_rounded,
                                    size: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${app.academicLevel} • Year ${app.yearOfStudy}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: (300 + (index * 50)).ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }
}

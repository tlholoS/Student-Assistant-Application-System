/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/student_viewmodel.dart';
import '../../services/navigation_service.dart';
import '../../routes/route_constants.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/premium_widgets.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  late String _studentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _studentId = context.read<AuthViewModel>().currentUserData!.id;
      context.read<StudentViewModel>().fetchDashboardData(_studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final studentVM = context.watch<StudentViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUserData;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: MeshBackground(
        child: SafeArea(
          child: ResponsiveLayout(
            child: RefreshIndicator(
              onRefresh: () => studentVM.fetchDashboardData(_studentId),
              child: _buildBody(studentVM, user?.firstName ?? 'Student', authVM),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NavigationService.navigateTo(RouteConstants.applicationForm),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Application', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E3192),
        elevation: 12,
      ).animate().scale(delay: 600.ms).fadeIn(),
    );
  }

  Widget _buildBody(StudentViewModel vm, String firstName, AuthViewModel authVM) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Premium Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: GoogleFonts.outfit(
                        fontSize: 16, 
                        fontWeight: FontWeight.w500, 
                        color: Colors.grey.shade600
                      ),
                    ),
                    Text(
                      '$firstName 👋',
                      style: GoogleFonts.outfit(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                GestureDetector(
                  onTap: () {
                    authVM.logout();
                    NavigationService.clearStackAndNavigateTo(RouteConstants.login);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 24),
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),
              ],
            ),
          ),
        ),

        // Quick Stats Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildStatCard('Total Apps', vm.myApplications.length.toString(), Icons.folder_outlined),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Active', 
                  vm.myApplications.where((a) => a.status == 'Pending').length.toString(), 
                  Icons.pending_actions_rounded
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              'Your Recent Submissions',
              style: GoogleFonts.outfit(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF1A1A1A)
              ),
            ).animate().fadeIn(delay: 400.ms),
          ),
        ),

        if (vm.isLoading && vm.myApplications.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (vm.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final app = vm.myApplications[index];
                  return _buildApplicationCard(app, index);
                },
                childCount: vm.myApplications.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2E3192), size: 24),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(dynamic app, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        opacity: 0.9,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => NavigationService.navigateTo(RouteConstants.applicationDetails, arguments: app),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(status: app.status),
                    Text(
                      'ID: ${app.id.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.firaCode(
                        fontSize: 11, 
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${app.academicLevel} Position',
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildIconLabel(Icons.calendar_today_rounded, 'Year ${app.yearOfStudy}'),
                    const SizedBox(width: 20),
                    _buildIconLabel(Icons.auto_awesome_mosaic_rounded, '${app.selectedModules.length} Modules'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (500 + (index * 100)).ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildIconLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30)
              ],
            ),
            child: Icon(Icons.assignment_add, size: 64, color: Colors.grey.shade200),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            'Start Your Journey',
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'You haven\'t submitted any applications yet.\nTap the button below to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../viewmodels/application_details_viewmodel.dart';
import '../../models/application_model.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/premium_widgets.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final ApplicationModel application;

  const ApplicationDetailsScreen({super.key, required this.application});

  @override
  State<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  bool _isEditing = false;
  late int _editYearOfStudy;
  late String _editAcademicLevel;

  final List<String> _academicLevels = ['Diploma', 'Advanced Diploma', 'Degree', 'Honours', 'Masters'];

  @override
  void initState() {
    super.initState();
    _editYearOfStudy = widget.application.yearOfStudy;
    _editAcademicLevel = widget.application.academicLevel;
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Text('Remove Application?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. All related documents will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final viewModel = context.read<ApplicationDetailsViewModel>();
              final success = await viewModel.deleteApplication(widget.application.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application deleted successfully'), backgroundColor: Colors.redAccent),
                );
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    final viewModel = context.read<ApplicationDetailsViewModel>();
    final success = await viewModel.updateApplication(
      applicationId: widget.application.id,
      yearOfStudy: _editYearOfStudy,
      academicLevel: _editAcademicLevel,
    );

    if (success && mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application updated successfully'), backgroundColor: Color(0xFF2E3192)),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ApplicationDetailsViewModel(),
      child: Consumer<ApplicationDetailsViewModel>(
        builder: (context, viewModel, child) {
          final bool isPending = widget.application.status.toLowerCase() == 'pending';

          return Scaffold(
            backgroundColor: const Color(0xFFF0F2F5),
            body: MeshBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, isPending),
                    Expanded(
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatusHeader(),
                                const SizedBox(height: 32),
                                _buildSectionHeader(Icons.info_outline_rounded, 'General Information'),
                                const SizedBox(height: 12),
                                _buildDetailsCard(),
                                const SizedBox(height: 32),
                                _buildSectionHeader(Icons.auto_awesome_mosaic_rounded, 'Requested Modules'),
                                const SizedBox(height: 12),
                                _buildModulesList(),
                                const SizedBox(height: 32),
                                _buildSectionHeader(Icons.description_outlined, 'Documentation'),
                                const SizedBox(height: 12),
                                _buildDocumentCard(),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          if (viewModel.isLoading)
                            Container(
                              color: Colors.white.withOpacity(0.5),
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isPending) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            'Application Info',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          if (isPending && !_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
            ),
          ],
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(() => _isEditing = false),
              style: IconButton.styleFrom(backgroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E3192).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.track_changes_rounded, color: Color(0xFF2E3192), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Status',
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.application.status,
                  style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          StatusChip(status: widget.application.status),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E3192)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: _isEditing
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Academic Level',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _editAcademicLevel,
                  items: _academicLevels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setState(() => _editAcademicLevel = val!),
                ),
                const SizedBox(height: 24),
                PremiumTextField(
                  label: 'Year of Study',
                  prefixIcon: Icons.numbers_rounded,
                  controller: TextEditingController(text: _editYearOfStudy.toString()),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(onPressed: _saveChanges, child: const Text('Save Updates')),
                ),
              ],
            )
          : Column(
              children: [
                _infoItem('Reference ID', '#${widget.application.id.substring(0, 8).toUpperCase()}', isCode: true),
                const Divider(height: 32, thickness: 1),
                _infoItem('Academic Level', widget.application.academicLevel),
                const Divider(height: 32, thickness: 1),
                _infoItem('Year of Study', 'Year ${widget.application.yearOfStudy}'),
              ],
            ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _infoItem(String label, String value, {bool isCode = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: isCode 
            ? GoogleFonts.firaCode(fontWeight: FontWeight.bold, color: const Color(0xFF2E3192), fontSize: 13)
            : GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildModulesList() {
    if (widget.application.selectedModules.isEmpty) {
      return Text('No modules selected', style: GoogleFonts.outfit(fontStyle: FontStyle.italic, color: Colors.grey));
    }
    return Column(
      children: widget.application.selectedModules.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3192).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bookmark_rounded, color: Color(0xFF2E3192), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.moduleCode, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(m.moduleName, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDocumentCard() {
    final hasDoc = widget.application.documentUrl != null;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (hasDoc ? Colors.redAccent : Colors.grey).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.picture_as_pdf_rounded, 
            color: hasDoc ? Colors.redAccent : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          hasDoc ? 'supporting_docs.pdf' : 'No document uploaded',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          hasDoc ? 'Tap to preview document' : 'Requires admin verification',
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: hasDoc ? const Icon(Icons.chevron_right_rounded) : null,
        onTap: () {
          if (hasDoc) {
            // Logic to launch URL would go here
          }
        },
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

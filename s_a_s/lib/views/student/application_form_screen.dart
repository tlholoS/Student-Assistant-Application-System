/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/application_form_viewmodel.dart';
import '../../models/module_model.dart';
import '../../widgets/premium_widgets.dart';
class ApplicationFormScreen extends StatefulWidget {
const ApplicationFormScreen({Key? key}) : super(key: key);
@override
State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}
class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
late TextEditingController _yearController;
@override
void initState() {
super.initState();
_yearController = TextEditingController();
}
@override
void dispose() {
_yearController.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
return ChangeNotifierProvider(
create: (_) => ApplicationFormViewModel(),
child: Scaffold(
backgroundColor: const Color(0xFFF0F2F5),
body: MeshBackground(
child: SafeArea(
child: Column(
children: [
_buildAppBar(context),
Expanded(
child: Consumer<ApplicationFormViewModel>(
builder: (context, viewModel, child) {
if (viewModel.isLoading && viewModel.availableModules.isEmpty) {
return const Center(child: CircularProgressIndicator());
}
if (viewModel.modulesLoadError != null && viewModel.availableModules.isEmpty) {
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
const SizedBox(height: 16),
Text(
viewModel.modulesLoadError!,
style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade700),
textAlign: TextAlign.center,
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: () => Navigator.pop(context),
child: const Text('Go Back'),
),
],
),
);
}
return SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
_buildHeaderInfo().animate().fadeIn().slideY(begin: 0.1, end: 0),
const SizedBox(height: 32),
_buildFormSection(
context,
title: 'Academic Context',
icon: Icons.school_rounded,
child: Column(
children: [
PremiumTextField(
label: 'Year of Study',
prefixIcon: Icons.numbers_rounded,
keyboardType: TextInputType.number,
controller: _yearController,
onChanged: viewModel.setYearOfStudy,
validator: (value) => value == null || value.isEmpty ? 'Required' : null,
),
const SizedBox(height: 24),
_buildDropdownLabel('Academic Level'),
DropdownButtonFormField<String>(
decoration: const InputDecoration(
prefixIcon: Icon(Icons.stairs_rounded),
),
value: viewModel.academicLevel,
items: viewModel.academicLevels.map((level) => DropdownMenuItem(value:
level, child: Text(level))).toList(),
onChanged: (value) { if (value != null) viewModel.setAcademicLevel(value); },
),
],
),
).animate().fadeIn(delay: 200.ms),
const SizedBox(height: 24),
_buildFormSection(
context,
title: 'Module Selection',
icon: Icons.book_rounded,
child: Column(
children: [
_buildDropdownLabel('Primary Module'),
DropdownButtonFormField<ModuleModel>(
decoration: const InputDecoration(prefixIcon: Icon(Icons.star_rounded)),
value: viewModel.selectedModule1,
items: viewModel.availableModules.map((m) => DropdownMenuItem(value:
m, child: Text('${m.moduleCode} - ${m.moduleName}'))).toList(),
onChanged: viewModel.setModule1,
),
const SizedBox(height: 20),
_buildDropdownLabel('Secondary Module (Optional)'),
DropdownButtonFormField<ModuleModel>(
decoration: const InputDecoration(prefixIcon:
Icon(Icons.add_circle_outline_rounded)),
value: viewModel.selectedModule2,
items: viewModel.availableModules.map((m) => DropdownMenuItem(value:
m, child: Text('${m.moduleCode} - ${m.moduleName}'))).toList(),
onChanged: viewModel.setModule2,
),
],
),
).animate().fadeIn(delay: 400.ms),
const SizedBox(height: 24),
_buildFormSection(
context,
title: 'Supporting Documents',
icon: Icons.attachment_rounded,
child: _buildUploadArea(context, viewModel),
).animate().fadeIn(delay: 600.ms),
if (viewModel.errorMessage != null)
Padding(
padding: const EdgeInsets.only(top: 16),
child: Text(
viewModel.errorMessage!,
style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight:
FontWeight.w600),
textAlign: TextAlign.center,
),
).animate().shake(),
const SizedBox(height: 32),
_buildEligibilityCheckbox(viewModel).animate().fadeIn(delay: 700.ms),
const SizedBox(height: 32),
_buildSubmitButton(context, viewModel).animate().fadeIn(delay: 800.ms),
const SizedBox(height: 60),
],
),
);
},
),
),
],
),
),
),
),
);
}
Widget _buildAppBar(BuildContext context) {
return Padding(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
child: Row(
children: [
IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(Icons.arrow_back_ios_new_rounded),
style: IconButton.styleFrom(
backgroundColor: Colors.white,
padding: const EdgeInsets.all(12),
),
),
const SizedBox(width: 12),
Text(
'New Application',
style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
),
],
),
);
}
Widget _buildHeaderInfo() {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: const Color(0xFF2E3192).withOpacity(0.08),
borderRadius: BorderRadius.circular(20),
border: Border.all(color: const Color(0xFF2E3192).withOpacity(0.1)),
),
child: Row(
children: [
const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2E3192), size: 24),
const SizedBox(width: 16),
Expanded(
child: Text(
'Apply for an assistant position by completing the sections below.',
style: GoogleFonts.outfit(
fontSize: 14,
color: const Color(0xFF2E3192),
fontWeight: FontWeight.w500,
),
),
),
],
),
);
}
Widget _buildFormSection(BuildContext context, {required String title, required IconData icon,
required Widget child}) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Padding(
padding: const EdgeInsets.only(left: 4, bottom: 12),
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
),
GlassCard(
padding: const EdgeInsets.all(24),
child: child,
),
],
);
}
Widget _buildDropdownLabel(String label) {
return Padding(
padding: const EdgeInsets.only(left: 4, bottom: 8),
child: Text(
label,
style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color:
Color(0xFF1A1A1A)),
),
);
}
Widget _buildUploadArea(BuildContext context, ApplicationFormViewModel viewModel) {
final hasFile = viewModel.documentBytes != null;
final isPicking = viewModel.isPickingFile;
return InkWell(
onTap: isPicking ? null : viewModel.pickDocument,
borderRadius: BorderRadius.circular(20),
child: Container(
padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
decoration: BoxDecoration(
color: hasFile ? const Color(0xFFE8F5E9).withOpacity(0.5) : Colors.white.withOpacity(0.5),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: hasFile ? Colors.green.shade300 : Colors.grey.shade300,
width: 2,
style: BorderStyle.solid,
),
),
child: Column(
children: [
if (isPicking)
const CircularProgressIndicator()
else ...[
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: hasFile ? Colors.green.shade100 : const Color(0xFF2E3192).withOpacity(0.1),
shape: BoxShape.circle,
),
child: Icon(
hasFile ? Icons.task_alt_rounded : Icons.file_upload_outlined,
size: 32,
color: hasFile ? Colors.green.shade700 : const Color(0xFF2E3192),
),
),
const SizedBox(height: 16),
Text(
viewModel.documentFileName ?? 'Upload academic record & CV',
style: GoogleFonts.outfit(
fontWeight: FontWeight.bold,
fontSize: 15,
color: hasFile ? Colors.green.shade800 : const Color(0xFF1A1A1A),
),
textAlign: TextAlign.center,
),
const SizedBox(height: 4),
Text(
hasFile ? 'Tap to replace file' : 'PDF or DOCX (Max 5MB)',
style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight:
FontWeight.w500),
),
],
],
),
),
);
}
Widget _buildEligibilityCheckbox(ApplicationFormViewModel viewModel) {
return Container(
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.6),
borderRadius: BorderRadius.circular(20),
border: Border.all(color: Colors.grey.shade200),
),
child: CheckboxListTile(
title: Text(
'I confirm all information is accurate and I meet the eligibility criteria.',
style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color:
Colors.grey.shade700)
),
value: viewModel.isEligible,
onChanged: viewModel.toggleEligibility,
activeColor: const Color(0xFF2E3192),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
),
);
}
Widget _buildSubmitButton(BuildContext context, ApplicationFormViewModel viewModel) {
return SizedBox(
height: 64,
width: double.infinity,
child: ElevatedButton(
onPressed: viewModel.isLoading
? null
: () async {
final authViewModel = context.read<AuthViewModel>();
final student = authViewModel.currentUserData;
if (student == null) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Session expired. Please log in again.')),
);
return;
}
final success = await viewModel.submitApplication(student);
if (context.mounted) {
if (success) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Application Submitted Successfully!', style:
GoogleFonts.outfit(fontWeight: FontWeight.w600)),
backgroundColor: const Color(0xFF2E3192),
behavior: SnackBarBehavior.floating,
duration: const Duration(seconds: 3),
),
);
Navigator.pop(context, true);
} else {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(viewModel.errorMessage ?? 'Submission failed. Please try again.', style:
GoogleFonts.outfit(fontWeight: FontWeight.w600)),
backgroundColor: Colors.redAccent,
behavior: SnackBarBehavior.floating,
),
);
}
}
},
child: viewModel.isLoading
? const SizedBox(
height: 24,
width: 24,
child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
)
: const Text('Submit Application'),
),
);
}
}
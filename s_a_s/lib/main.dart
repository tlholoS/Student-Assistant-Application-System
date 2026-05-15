/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routes/app_router.dart';
import 'routes/route_constants.dart';
import 'services/navigation_service.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://blhktfgowcirdmglgyjj.supabase.co',
    anonKey: 'sb_publishable_2BOM9z_CcVXF3aHyNKpQ5w_KxYdsFvN',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Check persistent login when app starts
  Future<void> _checkSession() async {
    final authVM = context.read<AuthViewModel>();
    await authVM.checkExistingSession();
    
    if (mounted) {
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Determine initial route based on existing session
    final authVM = context.watch<AuthViewModel>();
    String initialRoute = RouteConstants.login;
    
    if (authVM.currentUserData != null) {
      initialRoute = authVM.currentUserData!.role == 'admin' 
          ? RouteConstants.adminHome 
          : RouteConstants.studentHome;
    }

    return MaterialApp(
      title: 'Student Assistant Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3192),
          primary: const Color(0xFF2E3192),
          secondary: const Color(0xFFFFD700), // Gold accent
          surface: Colors.white,
          onSurface: const Color(0xFF1A1A1A),
          outline: Colors.grey.shade300,
        ),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).copyWith(
          displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A)),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            color: const Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E3192),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF2E3192).withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2E3192), width: 2),
          ),
          labelStyle: GoogleFonts.outfit(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          prefixIconColor: const Color(0xFF2E3192),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          color: Colors.white,
        ),
      ),
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
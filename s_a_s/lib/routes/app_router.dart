import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'route_constants.dart';
import '../models/application_model.dart';
import '../viewmodels/auth_viewmodel.dart';

import '../views/auth/login_screen.dart';
import '../views/student/student_home_screen.dart';
import '../views/student/application_form_screen.dart';
import '../views/student/application_details_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/auth/register_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case RouteConstants.studentHome:
        return _protectedRoute(
          settings: settings,
          child: const StudentHomeScreen(),
          allowedRole: 'student',
        );
        
      case RouteConstants.applicationForm:
        return _protectedRoute(
          settings: settings,
          child: const ApplicationFormScreen(),
          allowedRole: 'student',
        );
        
      case RouteConstants.applicationDetails:
        if (settings.arguments is ApplicationModel) {
          final app = settings.arguments as ApplicationModel;
          return _protectedRoute(
            settings: settings,
            child: ApplicationDetailsScreen(application: app),
            allowedRole: 'student', 
          );
        }
        return _errorRoute('Invalid arguments for Application Details. Expected ApplicationModel.');
        
      case RouteConstants.adminHome:
        return _protectedRoute(
          settings: settings,
          child: const AdminDashboardScreen(),
          allowedRole: 'admin',
        );
        
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  /// Authentication Guard: Checks if the user is logged in and matches the required role.
  static Route<dynamic> _protectedRoute({
    required RouteSettings settings, 
    required Widget child, 
    required String allowedRole
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final authVM = context.read<AuthViewModel>();
        final user = authVM.currentUserData;
        
        if (user == null) {
          // Not logged in -> Redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(context, RouteConstants.login, (route) => false);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (user.role != allowedRole) {
          // Unauthorized -> Redirect to their respective dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final route = user.role == 'admin' ? RouteConstants.adminHome : RouteConstants.studentHome;
            Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
          });
          return const Scaffold(body: Center(child: Text('Unauthorized Access')));
        }
        
        // Authorized -> Show the requested screen
        return child;
      },
    );
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Route Error')),
        body: Center(child: Text(message, style: const TextStyle(color: Colors.red))),
      );
    });
  }
}

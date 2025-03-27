import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'constants/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'GIS Application',
        theme: ThemeData(
          primaryColor: AppColors.primaryBlue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            primary: AppColors.primaryBlue,
            secondary: AppColors.secondaryBlue,
            error: AppColors.error,
            background: AppColors.backgroundPrimary,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            return FutureBuilder<bool>(
              future: authService.isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return snapshot.data == true
                    ? const DashboardScreen()
                    : const LoginScreen();
              },
            );
          },
        ),
      ),
    );
  }
}

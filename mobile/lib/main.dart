import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connection_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale data untuk format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // Cek status login
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  final user = isLoggedIn ? await authService.getCurrentUser() : null;

  runApp(MyApp(isLoggedIn: isLoggedIn, user: user));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final dynamic user;

  const MyApp({super.key, required this.isLoggedIn, this.user});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'WhatsApp Business Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF800000), // Maroon
              primary: const Color(0xFF800000), // Maroon
              secondary: const Color(0xFFD4AF37), // Gold
              tertiary: const Color(0xFF2C3E50), // Dark Blue
              background: const Color(0xFFF5F5F5), // Light Gray
              surface: Colors.white,
              error: const Color(0xFFDC3545), // Red
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onTertiary: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF800000),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardTheme(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800000),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF800000)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFDC3545)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            textTheme: TextTheme(
              displayLarge: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF800000),
              ),
              displayMedium: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF800000),
              ),
              bodyLarge: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF2C3E50),
              ),
              bodyMedium: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF2C3E50),
              ),
              titleLarge: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
          home:
              isLoggedIn && user != null
                  ? const HomeScreen()
                  : const LoginScreen(),
          routes: {'/connections': (context) => const ConnectionScreen()},
        );
      },
    );
  }
}

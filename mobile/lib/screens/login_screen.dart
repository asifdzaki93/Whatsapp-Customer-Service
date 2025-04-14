import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _rememberMe = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await _authService.getCredentials();
    if (credentials['email'] != null && credentials['password'] != null) {
      setState(() {
        _emailController.text = credentials['email']!;
        _passwordController.text = credentials['password']!;
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan terima syarat dan ketentuan terlebih dahulu'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (_rememberMe) {
        await _authService.saveCredentials(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await _authService.clearCredentials();
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40.h),
                // Logo atau Icon
                Icon(
                  Icons.message,
                  size: 80.w,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 24.h),
                // Judul
                Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                // Subtitle
                Text(
                  'Silakan masuk untuk melanjutkan',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                // Form Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email Anda',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                // Form Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi Anda',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8.h),
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() => _rememberMe = value ?? false);
                            },
                          ),
                        ),
                        Text('Ingat Saya', style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password screen
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Terms of Use
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Saya setuju dengan ',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Syarat & Ketentuan'),
                            content: SingleChildScrollView(
                              child: Text(
                                '1. Aplikasi ini digunakan untuk mengelola WhatsApp Business\n\n'
                                '2. Pengguna harus mematuhi kebijakan WhatsApp\n\n'
                                '3. Data pengguna akan disimpan dengan aman\n\n'
                                '4. Pengguna bertanggung jawab atas penggunaan aplikasi\n\n'
                                '5. Kami berhak menghentikan layanan jika melanggar ketentuan',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Tutup'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Syarat & Ketentuan',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text('Masuk', style: TextStyle(fontSize: 16.sp)),
                ),
                SizedBox(height: 16.h),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text('Daftar', style: TextStyle(fontSize: 12.sp)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

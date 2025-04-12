class ApiConfig {
  // Ganti IP address sesuai dengan IP komputer Anda yang menjalankan backend
  static const String baseUrl =
      'http://192.168.0.101:9003'; // IP komputer Anda dengan port 9003

  // Environment Token untuk Signup
  static const String envToken = '123456'; // Sesuaikan dengan token di backend

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String users = '/users';
  static const String tickets = '/tickets';
  static const String contacts = '/contacts';
  static const String whatsapp = '/whatsapp';
  static const String settings = '/settings';

  // WebSocket
  static const String wsUrl =
      'ws://192.168.0.101:9003'; // IP komputer Anda dengan port 9003

  static String fixMediaUrl(String? url) {
    if (url == null) return '';

    try {
      // Hapus port 443 jika ada
      String fixedUrl = url.replaceAll(':443', '');

      // Hapus port ganda jika ada
      if (fixedUrl.contains('::')) {
        fixedUrl = fixedUrl.replaceAll('::', ':');
      }

      // Ganti IP lokal atau localhost dengan IP yang benar
      if (fixedUrl.contains('192.168.100.164')) {
        fixedUrl = fixedUrl.replaceAll(
          '192.168.100.164:9003',
          baseUrl.replaceAll('http://', ''),
        );
      }
      if (fixedUrl.contains('localhost')) {
        fixedUrl = fixedUrl.replaceAll(
          'localhost:9003',
          baseUrl.replaceAll('http://', ''),
        );
      }

      // Pastikan URL dimulai dengan http:// atau https://
      if (!fixedUrl.startsWith('http://') && !fixedUrl.startsWith('https://')) {
        fixedUrl = 'http://$fixedUrl';
      }

      print('Fixed media URL: $fixedUrl');
      return fixedUrl;
    } catch (e) {
      print('Error fixing media URL: $e');
      return url;
    }
  }
}

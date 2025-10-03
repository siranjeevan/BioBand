import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl {
    try {
      return dotenv.env['API_BASE_URL'] ?? 'https://bio-band-backend.vercel.app';
    } catch (e) {
      return 'https://bio-band-backend.vercel.app';
    }
  }
}
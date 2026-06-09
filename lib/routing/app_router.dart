import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/photo_upload_screen.dart';
import '../screens/route_recording_screen.dart';
import '../screens/route_history_screen.dart';
import '../screens/profile_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String map = '/map';
  static const String photoUpload = '/photo-upload';
  static const String routeRecording = '/route-recording';
  static const String routeHistory = '/route-history';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      map: (context) => const MapScreen(),
      photoUpload: (context) => const PhotoUploadScreen(),
      routeRecording: (context) => const RouteRecordingScreen(),
      routeHistory: (context) => const RouteHistoryScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }
}

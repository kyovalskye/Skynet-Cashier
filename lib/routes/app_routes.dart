import 'package:flutter/material.dart';
import 'package:skynet_internet_cafe/presentation/screens/home_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/login_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/panel_user_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/schedule_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/profile_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/purchase_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/report_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/seat_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/settings_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/user_management_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/home': (_) => const HomePage(),
    '/login': (_) => const LoginPage(),
    '/userpanel': (_) => const PanelUserPage(),
    '/reports': (_) => const ReportManagementPage(),
    '/profile': (_) => const ProfilePage(),
    '/settings': (_) => const SettingsPage(),
    '/purchase': (_) => const PurchasePage(),
    '/seat': (_) => const SeatManagementPage(),
    '/user-management': (_) => const UserManagementPage(),
  };
}

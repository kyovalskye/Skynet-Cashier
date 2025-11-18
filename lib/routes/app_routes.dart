import 'package:flutter/material.dart';
import 'package:skynet_internet_cafe/presentation/screens/home_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/login_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/panel_user_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/customer_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/report_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/seat_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/settings_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/home': (_) => const HomePage(),
    '/login': (_) => const LoginPage(),
    '/userpanel': (_) => const PanelUserPage(),
    '/reports': (_) => const ReportManagementPage(),
    '/profile': (_) => const CustomerManagementPage(),
    '/settings': (_) => const SettingsPage(),
    '/seat': (_) => const SeatManagementPage(),
  };
}

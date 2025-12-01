import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';
import 'package:skynet_internet_cafe/presentation/screens/admin_settings_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/customer_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/home_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/login_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/panel_user_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/schedule_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/profile_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/purchase_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/report_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/seat_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/settings_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/stock_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/user_management_page.dart';
import 'package:skynet_internet_cafe/presentation/logic/navbar_cubit.dart';
import 'package:skynet_internet_cafe/presentation/logic/appbar_cubit.dart';
import 'package:skynet_internet_cafe/presentation/logic/purchase_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavbarCubit()),
        BlocProvider(create: (_) => AppbarCubit()),
        BlocProvider(create: (_) => PurchaseCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/customer': (_) => const CustomerManagementPage(),
        '/schedule': (_) => const ScheduleManagementPage(),
        '/userpanel': (_) => const PanelUserPage(),
        '/purchase': (_) => const PurchasePage(),
        '/stocks': (_) => const StockManagementPage(),
        '/reports': (_) => const ReportManagementPage(),
        '/seat': (_) => const SeatManagementPage(),
        '/profile': (_) => const ProfilePage(),
        '/settings': (_) => const SettingsPage(),
        '/user-management': (_) => const UserManagementPage(),
        '/admin-settings': (_) => const AdminSettingsPage(),
      },
      initialRoute: '/login',
    );
  }
}

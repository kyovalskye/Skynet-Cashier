import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/core/service/supabase_service.dart';
import 'package:skynet_internet_cafe/presentation/screens/home_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/login_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/panel_user_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/customer_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/profile_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/purchase_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/report_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/seat_management_page.dart';
import 'package:skynet_internet_cafe/presentation/screens/settings_page.dart';
import 'package:skynet_internet_cafe/presentation/logic/navbar_cubit.dart';
import 'package:skynet_internet_cafe/presentation/logic/appbar_cubit.dart';
import 'package:skynet_internet_cafe/presentation/screens/stocks_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavbarCubit()),
        BlocProvider(create: (_) => AppbarCubit()),
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
        '/schedule': (_) => const CustomerManagementPage(),
        '/userpanel': (_) => const PanelUserPage(),
        '/purchase': (_) => const PurchasePage(),
        '/stocks': (_) => const StocksPage(),
        '/reports': (_) => const ReportManagementPage(),
        '/seat': (_) => const SeatManagementPage(),
        '/profile': (_) => const CustomerManagementPage(),
        '/settings': (_) => const SettingsPage(),
      },
      initialRoute: '/home',
    );
  }
}

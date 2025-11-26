import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/presentation/logic/login_cubit.dart';
import 'package:skynet_internet_cafe/presentation/logic/purchase_cubit.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Login Cubit
        BlocProvider(create: (context) => LoginCubit()),

        // Purchase Cubit - load products saat pertama kali
        BlocProvider(create: (context) => PurchaseCubit()..loadProducts()),

        // Tambahkan cubit lainnya di sini
        // BlocProvider(
        //   create: (context) => ComputerCubit(),
        // ),
        // BlocProvider(
        //   create: (context) => ReportCubit(),
        // ),
      ],
      child: child,
    );
  }
}

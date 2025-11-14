import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skynet_internet_cafe/presentation/logic/login_cubit.dart';
import 'package:skynet_internet_cafe/presentation/screens/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, String>(
        listener: (context, state) {
          if (state == 'success') {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login berhasil')));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state == 'failed') {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Login gagal')));
          }
        },
        builder: (context, state) {
          // ⚠️ Panggil signupIfNotExist setelah widget build
          if (state == '') {
            Future.microtask(() {
              context.read<LoginCubit>().signupIfNotExist();
            });
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Login Warnet')),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: emailC,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'admin@skynet.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordC,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state == 'loading'
                          ? null
                          : () {
                              context.read<LoginCubit>().login(
                                emailC.text.trim(),
                                passwordC.text.trim(),
                              );
                            },
                      child: Text(
                        state == 'loading' ? 'Loading...' : 'Login',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Test Credentials:\nadmin@skynet.com / adminwarnet\nkasir1@skynet.com / kasirwarnet',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    emailC.dispose();
    passwordC.dispose();
    super.dispose();
  }
}

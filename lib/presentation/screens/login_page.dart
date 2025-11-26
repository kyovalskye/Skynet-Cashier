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
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocConsumer<LoginCubit, String>(
        listener: (context, state) {
          if (state == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Login berhasil'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state == 'failed') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Login gagal. Periksa email dan password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (!_initialized && state == '') {
            _initialized = true;
            Future.microtask(() {
              context.read<LoginCubit>().signupIfNotExist();
            });
          }

          return Scaffold(
            backgroundColor: Color(0xff0A0A0B),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/ambanet.png',
                      width: 500,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    // Logo atau Icon
                    // Container(
                    //   width: 100,
                    //   height: 100,
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.shade100,
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: Icon(
                    //     Icons.computer,
                    //     size: 50,
                    //     color: Colors.blue.shade700,
                    //   ),
                    // ),
                    SizedBox(height: 60),

                    // Email Field
                    TextField(
                      style: TextStyle(
                        color: Colors.white
                      ),
                      controller: emailC,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Masukkan email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: state != 'loading',
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                       style: TextStyle(color: Colors.white),
                      controller: passwordC,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Masukkan password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                      enabled: state != 'loading',
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state == 'loading'
                            ? null
                            : () {
                                context.read<LoginCubit>().login(
                                  emailC.text.trim(),
                                  passwordC.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            width: 2,
                            color: Color(0xff006783),
                          ),
                          backgroundColor: Color(0xff10333C),
                          shape: RoundedRectangleBorder(
                            
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: state == 'loading'
                            ? const SizedBox(
                                width: 20, 
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xff00B3DB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Have you joined previously? Login to continue your manage')

                    // Test Credentials
                    // Container(
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey.shade100,
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.grey.shade300),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Icon(
                    //             Icons.info_outline,
                    //             size: 16,
                    //             color: Colors.grey.shade600,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           Text(
                    //             'Test Credentials:',
                    //             style: TextStyle(
                    //               fontSize: 12,
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.grey.shade700,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Text(
                    //         '👤 Admin:\nadmin@skynet.com / adminwarnet',
                    //         style: TextStyle(
                    //           fontSize: 11,
                    //           color: Colors.grey.shade600,
                    //           height: 1.4,
                    //         ),
                    //       ),
                    //       const SizedBox(height: 8),
                    //       Text(
                    //         '💼 Kasir:\nkasir1@skynet.com / kasirwarnet',
                    //         style: TextStyle(
                    //           fontSize: 11,
                    //           color: Colors.grey.shade600,
                    //           height: 1.4,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
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

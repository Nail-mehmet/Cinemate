import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/presentation/components/my_button.dart';
import 'package:Cinemate/features/auth/presentation/components/my_text_field.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/themes/font_theme.dart';

import '../cubits/auth_states.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;

  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void login() {
    final String email = emailController.text.trim();
    final String pw = pwController.text.trim();

    if (email.isEmpty && pw.isEmpty) {
      _showErrorSnackbar(context, "Lütfen e-posta ve şifrenizi giriniz.");
      return;
    } else if (email.isEmpty) {
      _showErrorSnackbar(context, "Lütfen e-posta adresinizi giriniz.");
      return;
    } else if (pw.isEmpty) {
      _showErrorSnackbar(context, "Lütfen şifrenizi giriniz.");
      return;
    }

    final authCubit = context.read<AuthCubit>();
    authCubit.login(email, pw);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required bool obscured,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*  Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(label,
              style: AppTextStyles.bold
                  .copyWith(color: Theme.of(context).colorScheme.primary)),
        ),*/
        const SizedBox(height: 5),
        MyTextField(
          controller: controller,
          hintText: hintText,
          obscureText: obscured,
        ),
      ],
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
      if (state is AuthError) {
        _showErrorSnackbar(context, state.message);
      }
    },
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/cinemate.png"),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Giriş Yap",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Aşağıdaki bilgileri doldurun veya hesabınızla giriş yapın.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  _buildLabeledTextField(
                      label: "email",
                      controller: emailController,
                      hintText: "mail giriniz",
                      maxLines: 1,
                      obscured: false),
                  SizedBox(
                    height: 10,
                  ),
                  _buildLabeledTextField(
                      label: "şifre",
                      controller: pwController,
                      hintText: "şifrenizi giriniz",
                      maxLines: 1,
                      obscured: true),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: login,
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Koyu gri, istersen Theme'den alabilirim
                        borderRadius:
                            BorderRadius.circular(30), // Daha oval görünüm
                      ),
                      child: const Center(
                        child: Text(
                          "Giriş Yap",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                 /* Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Veya şu hesapla giriş yap",
                            style: TextStyle(color: Colors.grey[600])),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialIcon(Icons.apple),
                      const SizedBox(width: 12),
                      socialIcon(Icons.g_mobiledata),
                      const SizedBox(width: 12),
                      socialIcon(Icons.facebook),
                    ],
                  ),*/
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hesabınız Yok Mu ? ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Kayıt Ol",
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget socialIcon(IconData iconData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(iconData, size: 24),
    );
  }
}

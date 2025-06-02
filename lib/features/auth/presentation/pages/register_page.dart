import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/presentation/components/my_text_field.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/themes/font_theme.dart';

import '../cubits/auth_states.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final confirmController = TextEditingController();
  final pwController = TextEditingController();

  void register() {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String pw = pwController.text;
    final String confirmPw = confirmController.text;

    final authCubit = context.read<AuthCubit>();

    if (name.isEmpty || email.isEmpty || pw.isEmpty || confirmPw.isEmpty) {
      showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    if (pw != confirmPw) {
      showMessage("Şifreler aynı değil.");
      return;
    }

    final pwError = validatePassword(pw);
    if (pwError != null) {
      showMessage(pwError);
      return;
    }

    authCubit.register(name, email, pw);
  }

  String? validatePassword(String password) {
    if (password.length < 8) {
      return "Şifre en az 8 karakter olmalı.";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Şifre en az bir büyük harf içermeli.";
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Şifre en az bir küçük harf içermeli.";
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Şifre en az bir rakam içermeli.";
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      return "Şifre en az bir özel karakter (!@#\$&*~) içermeli.";
    }
    return null;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    pwController.dispose();
    confirmController.dispose();
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
       /* Padding(
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inverse = Theme.of(context).colorScheme.inversePrimary;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset("assets/images/cinemate.png"),
                SizedBox(height: 20,),
                const Text(
                  "Hesap Oluştur",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hesabınızı oluşturmak için aşağıdaki bilgileri doldurunuz.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
      
                _buildLabeledTextField(
                    label: "İsim",
                    controller: nameController,
                    hintText: "Kullanıcı Adınızı Giriniz",
                    maxLines: 1,
                    obscured: false),
      
                SizedBox(
                  height: 10,
                ),
                _buildLabeledTextField(
                    label: "email",
                    controller: emailController,
                    hintText: "mailiniz giriniz",
                    maxLines: 1,
                    obscured: false),
      
                const SizedBox(height: 12),
      
                _buildLabeledTextField(
                    label: "Şifre",
                    controller: pwController,
                    hintText: "Güçlü bir şifre belirleyiniz",
                    maxLines: 1,
                    obscured: true),
      
                const SizedBox(height: 12),
      
                // Confirm Password
                _buildLabeledTextField(
                    label: "Şifre Tekrar",
                    controller: confirmController,
                    hintText: "Şifrenizi tekrar giriniz",
                    maxLines: 1,
                    obscured: true),
      
                const SizedBox(height: 12),
      
                // Terms Checkbox - opsiyonel görsel için koymadım
      
                const SizedBox(height: 12),
      
                // Sign Up Button
                GestureDetector(
                  onTap: register,
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary, // Koyu gri, istersen Theme'den alabilirim
                      borderRadius:
                          BorderRadius.circular(30), // Daha oval görünüm
                    ),
                    child: const Center(
                      child: Text(
                        "Kaydol",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(height: 30),
      
                // Social login
                Row(
                  children: [
                    const Expanded(child: Divider(thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Veya şu hesapla kaydol",
                          style: TextStyle(color: Colors.grey[600])),
                    ),
                    const Expanded(child: Divider(thickness: 1)),
                  ],
                ),
                const SizedBox(height: 16),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _googleSignInButton(),
                    const SizedBox(width: 12),
                    socialIcon(Icons.g_mobiledata),
                    const SizedBox(width: 12),
                    socialIcon(Icons.facebook),
                  ],
                ),
      
                const SizedBox(height: 30),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Zaten bir hesabım var? ",
                        style: TextStyle(color: primary)),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Giriş Yap",
                        style: TextStyle(
                            color: inverse, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return GestureDetector(
      onTap: () {
        final authCubit = context.read<AuthCubit>();
        authCubit.signInWithGoogle();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Image.asset(
          "assets/icons/google.png", // Google icon asset'i
          width: 24,
          height: 24,
        ),
      ),
    );
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

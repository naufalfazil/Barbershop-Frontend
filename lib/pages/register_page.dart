
import 'package:flutter/material.dart';
import '../service/api.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // FORM DAN CONTROLLER
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // STATE
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool loading = false;

  // WARNA APLIKASI
  static const Color teal = Color.fromARGB(255, 233, 210, 9);
  static const Color panelColor = Color.fromARGB(255, 12, 12, 12);
  static const Color inputColor = Color(0xFF252525);
  static const Color borderColor = Color(0xFF3A3A3A);
  static const Color primaryText = Color(0xFFF5F5F5);
  static const Color secondaryText = Color(0xFFAAAAAA);

  // REGISTER
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      await ApiService.post(
        '/auth/register',
        body: {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'no_telepon': phoneController.text.trim(),
          'password': passwordController.text,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // DISPOSE CONTROLLER
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();    
    super.dispose();
  }

  // INPUT DECORATION
  InputDecoration inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: secondaryText,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 19,
        color: secondaryText,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: secondaryText,
          width: 1.5,
        ),
      ),
    );
  }

  // HEADER DENGAN GAMBAR
  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 350,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/barbershop.webp',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          const Positioned(
            top: 75,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join Us!',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                Text(
                  'Create your CukurIn account',
                  style: TextStyle(
                    fontSize: 15,
                    color: primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // INPUT NAMA
  Widget _buildNameField() {
    return TextFormField(
      controller: nameController,
      style: const TextStyle(color: primaryText),
      decoration: inputDecoration(
        hintText: 'Nama Lengkap',
        prefixIcon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama wajib diisi';
        }
        return null;
      },
    );
  }

  // INPUT EMAIL
  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: primaryText),
      decoration: inputDecoration(
        hintText: 'Email',
        prefixIcon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email wajib diisi';
        }

        if (!RegExp(
          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
        ).hasMatch(value.trim())) {
          return 'Format email tidak valid';
        }

        return null;
      },
    );
  }

  // INPUT NOMOR TELEPON
  Widget _buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: primaryText),
      decoration: inputDecoration(
        hintText: 'Nomor Telepon',
        prefixIcon: Icons.phone_outlined,
      ),
    );
  }

  // INPUT PASSWORD
  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: hidePassword,
      style: const TextStyle(color: primaryText),
      decoration: inputDecoration(
        hintText: 'Password',
        prefixIcon: Icons.lock_outline,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              hidePassword = !hidePassword;
            });
          },
          icon: Icon(
            hidePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: secondaryText,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password wajib diisi';
        }

        if (value.length < 8) {
          return 'Password minimal 8 karakter';
        }

        return null;
      },
    );
  }

  // TOMBOL REGISTER
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade800,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // PANEL REGISTER
  Widget _buildRegisterPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 25, 28, 30),
      decoration: const BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: primaryText,
                  ),
                ),
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            _buildNameField(),

            const SizedBox(height: 15),

            _buildEmailField(),

            const SizedBox(height: 15),
            _buildPasswordField(),

            const SizedBox(height: 15),

            _buildPhoneField(),

            const SizedBox(height: 25),

            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  // TAMPILAN UTAMA
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: panelColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: 900,
                child: Stack(
                  children: [
                    _buildHeader(),

                    Positioned(
                      top: 200,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildRegisterPanel(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

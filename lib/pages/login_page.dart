import 'package:flutter/material.dart';
import 'package:frontend_asas/pages/customer/home_page.dart';
import 'package:frontend_asas/pages/register_page.dart';
import '../service/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // FORM DAN CONTROLLER
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // STATE
  bool hidePassword = true;
  bool loading = false;

  // WARNA APLIKASI
  static const Color teal = Color.fromARGB(255, 233, 210, 9);
  static const Color panelColor = Color.fromARGB(255, 12, 12, 12);
  static const Color inputColor = Color(0xFF252525);
  static const Color borderColor = Color(0xFF3A3A3A);
  static const Color primaryText = Color(0xFFF5F5F5);
  static const Color secondaryText = Color(0xFFAAAAAA); 

  // LOGIN
  
Future<void> login() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    loading = true;
  });

  try {
    final response = await ApiService.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    final user = response['user'];
    final role = user['role'];

    if (role == 'customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: user['name'],
          ),
        ),
      );
    } else if (role == 'admin') {
      // TODO: Navigasi ke AdminPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard Admin belum tersedia.'),
        ),
      );
    } else if (role == 'kasir') {
      // TODO: Navigasi ke KasirPage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard Kasir belum tersedia.'),
        ),
      );
    } else {
      throw Exception('Role pengguna tidak dikenali.');
    }
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
    emailController.dispose();
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

          // OVERLAY GAMBAR
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // TEKS HEADER
          const Positioned(
            top: 95,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
                Text(
                  'Welcome to CukurIn',
                  style: TextStyle(
                    fontSize: 15,
                    color:primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // INPUT EMAIL
  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(
        color: primaryText,
        fontSize: 15,
      ),
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

  // INPUT PASSWORD
  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: hidePassword,
      style: const TextStyle(
        color: primaryText,
        fontSize: 15,
      ),
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

        return null;
      },
    );
  }

  // LINK REGISTER
  Widget _buildRegisterLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Belum punya akun?',
            style: TextStyle(
              color: primaryText,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: teal,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TOMBOL LOGIN
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : login,
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
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // PANEL FORM LOGIN
  Widget _buildLoginPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
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
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),

            const SizedBox(height: 25),

            _buildEmailField(),

            const SizedBox(height: 18),

            _buildPasswordField(),

            _buildRegisterLink(),

            const SizedBox(height: 15),

            _buildLoginButton(),
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
                height: constraints.maxHeight < 760
                    ? 760
                    : constraints.maxHeight,
                child: Stack(
                  children: [
                    _buildHeader(),

                    Positioned(
                      top: 200,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildLoginPanel(),
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

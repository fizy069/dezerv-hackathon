import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWidget extends StatefulWidget {
  final VoidCallback onGetStarted;
  const ProfileWidget({super.key, required this.onGetStarted});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AppCubit>();
    _nameController.text = cubit.state.username ?? '';
    _ageController.text = cubit.state.age?.toString() ?? '';
    _incomeController.text = cubit.state.income?.toString() ?? '';
    _emailController.text = cubit.state.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _incomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<AppCubit>();

      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please enter your name")));
        return;
      }

      await cubit.updateUsername(_nameController.text);

      if (_ageController.text.isNotEmpty) {
        await cubit.updateAge(int.parse(_ageController.text));
      }

      if (_incomeController.text.isNotEmpty) {
        await cubit.updateIncome(double.parse(_incomeController.text));
      }

      if (_emailController.text.isNotEmpty) {
        await cubit.updateEmail(_emailController.text);
      }

      widget.onGetStarted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 60,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Create your account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Join IvyTracker to manage your expenses",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "Enter your full name",
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email Address",
                    hint: "Enter your email address",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ageController,
                    label: "Age",
                    hint: "Enter your age",
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final age = int.tryParse(value);
                        if (age == null || age < 18 || age > 100) {
                          return 'Please enter a valid age between 18-100';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _incomeController,
                    label: "Monthly Income",
                    hint: "Enter your monthly income",
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final income = double.tryParse(value);
                        if (income == null || income <= 0) {
                          return 'Please enter a valid income amount';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildSignUpButton(),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.grey.shade600),
                          children: [
                            TextSpan(
                              text: "Sign in",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        labelText: "Password",
        hintText: "Create a password",
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveUserData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.blue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:expense_advisor/helpers/color.helper.dart';
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
  final _formKey = GlobalKey<FormState>();

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

      // Update user information
      await cubit.updateUsername(_nameController.text);

      // Save age if provided
      if (_ageController.text.isNotEmpty) {
        await cubit.updateAge(int.parse(_ageController.text));
      }

      // Save income if provided
      if (_incomeController.text.isNotEmpty) {
        await cubit.updateIncome(double.parse(_incomeController.text));
      }

      // Save email if provided
      if (_emailController.text.isNotEmpty) {
        await cubit.updateEmail(_emailController.text);
      }

      widget.onGetStarted();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_balance_wallet, size: 70),
                  const SizedBox(height: 25),
                  Text(
                    "Hi! welcome to expense_advisor",
                    style: theme.textTheme.headlineMedium!.apply(
                      color: theme.colorScheme.primary,
                      fontWeightDelta: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Tell us about yourself",
                    style: theme.textTheme.bodyLarge!.apply(
                      color: ColorHelper.darken(
                        theme.textTheme.bodyLarge!.color!,
                      ),
                      fontWeightDelta: 1,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      prefixIcon: const Icon(Icons.account_circle),
                      hintText: "Enter your name",
                      label: const Text("Name"),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      prefixIcon: const Icon(Icons.email),
                      hintText: "Enter your email address",
                      label: const Text("Email"),
                    ),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                      hintText: "Enter your age",
                      label: const Text("Age"),
                    ),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _incomeController,
                    decoration: InputDecoration(
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      prefixIcon: const Icon(Icons.currency_rupee),
                      hintText: "Enter your monthly income",
                      label: const Text("Monthly Income"),
                    ),
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
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveUserData,
        label: const Row(
          children: <Widget>[
            Text("Next"),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }
}

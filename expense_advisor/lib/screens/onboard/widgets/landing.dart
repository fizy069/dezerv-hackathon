import 'package:expense_advisor/helpers/color.helper.dart';
import 'package:expense_advisor/widgets/buttons/button.dart';
import 'package:expense_advisor/bloc/cubit/app_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingPage extends StatefulWidget {
  final VoidCallback onGetStarted;
  const LandingPage({super.key, required this.onGetStarted});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ageController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _saveUserData() {
    if (_formKey.currentState!.validate()) {
      final appCubit = context.read<AppCubit>();
      
      // Save age if provided
      if (_ageController.text.isNotEmpty) {
        appCubit.updateAge(int.parse(_ageController.text));
      }
      
      // Save income if provided
      if (_incomeController.text.isNotEmpty) {
        appCubit.updateIncome(double.parse(_incomeController.text));
      }
      
      // Continue to next screen
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
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            height: MediaQuery.of(context).size.height - 
                MediaQuery.of(context).padding.top - 
                MediaQuery.of(context).padding.bottom,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "IvyTrack",
                    style: theme.textTheme.headlineLarge!.apply(
                      color: theme.colorScheme.primary,
                      fontWeightDelta: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Easy method to manage your savings",
                    style: theme.textTheme.headlineMedium!.apply(
                      color: ColorHelper.lighten(theme.colorScheme.primary, 0.1),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.check_circle, color: theme.colorScheme.primary),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text("Using our app, manage your finances."),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.check_circle, color: theme.colorScheme.primary),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "Simple expense monitoring for more accurate budgeting",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(Icons.check_circle, color: theme.colorScheme.primary),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          "Keep track of your spending whenever and wherever you are.",
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 30),
                  // Text(
                  //   "Tell us about yourself",
                  //   style: theme.textTheme.titleMedium!.copyWith(
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 15),
                  // TextFormField(
                  //   controller: _ageController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Your Age',
                  //     border: OutlineInputBorder(),
                  //     prefixIcon: Icon(Icons.person),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //   validator: (value) {
                  //     if (value != null && value.isNotEmpty) {
                  //       final age = int.tryParse(value);
                  //       if (age == null || age < 18 || age > 100) {
                  //         return 'Please enter a valid age between 18-100';
                  //       }
                  //     }
                  //     return null;
                  //   },
                  // ),
                  // const SizedBox(height: 15),
                  // TextFormField(
                  //   controller: _incomeController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Monthly Income',
                  //     border: OutlineInputBorder(),
                  //     prefixIcon: Icon(Icons.currency_rupee),
                  //   ),
                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: [
                  //     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  //   ],
                  //   validator: (value) {
                  //     if (value != null && value.isNotEmpty) {
                  //       final income = double.tryParse(value);
                  //       if (income == null || income <= 0) {
                  //         return 'Please enter a valid income amount';
                  //       }
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const Expanded(child: SizedBox()),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: AppButton(
                      color: theme.colorScheme.inversePrimary,
                      isFullWidth: true,
                      onPressed: _saveUserData,
                      size: AppButtonSize.large,
                      label: "Get Started",
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

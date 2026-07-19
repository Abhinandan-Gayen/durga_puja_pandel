import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final auth = context.read<AuthController>();
    await auth.resetPassword(_emailController.text.trim());
    if (!mounted) {
      return;
    }
    if (auth.errorMessage != null) {
      SnackbarHelper.showError(context, auth.errorMessage!);
    } else {
      SnackbarHelper.showSuccess(context, 'Password reset email sent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Consumer<AuthController>(
            builder: (context, auth, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    prefixIcon: Icons.mail_outline,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Send reset link',
                    icon: Icons.mark_email_read_outlined,
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

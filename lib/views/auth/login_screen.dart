import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthController auth = context.read<AuthController>();

      /*
       * User আগে থেকেই login করা থাকলে
       * সরাসরি admin dashboard-এ পাঠাবে।
       */
      if (auth.isInitialized && auth.isAdminLoggedIn && auth.isAdmin) {
        Get.offAllNamed('/admin');
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final bool formIsValid = _formKey.currentState?.validate() ?? false;

    if (!formIsValid) {
      return;
    }

    final AuthController auth = context.read<AuthController>();

    await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (auth.errorMessage != null) {
      SnackbarHelper.showError(context, auth.errorMessage!);
      return;
    }

    if (auth.isAdminLoggedIn && auth.isAdmin) {
      Get.offAllNamed('/admin');
      return;
    }

    SnackbarHelper.showError(context, 'Admin account load করা যায়নি।');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (BuildContext context, AuthController auth, Widget? child) {
        if (!auth.isInitialized) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFF8ED),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFB91419)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8ED),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLogo(),

                              const SizedBox(height: 22),

                              const Text(
                                'Admin Login',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D1A15),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Pujo Pandal Guide dashboard পরিচালনা করতে login করুন',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.brown.shade400,
                                ),
                              ),

                              const SizedBox(height: 30),

                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFB91419,
                                    ).withValues(alpha: 0.10),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    CustomTextField(
                                      controller: _emailController,
                                      label: 'Gmail ID',
                                      hintText: 'example@gmail.com',
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: Validators.email,
                                      prefixIcon: Icons.mail_outline,
                                    ),

                                    const SizedBox(height: 16),

                                    CustomTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      hintText: 'Enter password',
                                      obscureText: !_passwordVisible,
                                      textInputAction: TextInputAction.done,
                                      validator: Validators.password,
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _passwordVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      onFieldSubmitted: (_) {
                                        _submit();
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: auth.isLoading
                                            ? null
                                            : () {
                                                Get.toNamed('/forgot-password');
                                              },
                                        child: const Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            color: Color(0xFFB91419),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    CustomButton(
                                      label: 'Login',
                                      icon: Icons.login_rounded,
                                      isLoading: auth.isLoading,
                                      onPressed: auth.isLoading
                                          ? null
                                          : _submit,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified_user_outlined,
                                    size: 17,
                                    color: Colors.brown.shade300,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Only authorised administrators',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: const Color(0xFFB91419),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFFFD17B), width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB91419).withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.temple_hindu_rounded,
          size: 48,
          color: Color(0xFFFFD17B),
        ),
      ),
    );
  }
}

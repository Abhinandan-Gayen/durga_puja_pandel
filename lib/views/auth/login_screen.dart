import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _primaryRed = Color(0xFFE70E19);
  static const Color _deepRed = Color(0xFFB8000A);
  static const Color _darkRed = Color(0xFF8F0008);
  static const Color _cream = Color(0xFFFFF8EC);
  static const Color _surface = Color(0xFFFFFCF7);
  static const Color _gold = Color(0xFFFFD17B);
  static const Color _darkText = Color(0xFF332825);
  static const Color _mutedText = Color(0xFF7A6964);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AuthController auth = context.read<AuthController>();

      // Send an already authenticated administrator directly to the dashboard.
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

    SnackbarHelper.showError(
      context,
      'Unable to load the administrator account.',
    );
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
          return const AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
              backgroundColor: _cream,
              body: Center(
                child: CircularProgressIndicator(color: _primaryRed),
              ),
            ),
          );
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: _cream,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double horizontalPadding = constraints.maxWidth < 360
                      ? 16
                      : 22;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: <Widget>[
                          _buildHeader(context),
                          Transform.translate(
                            offset: const Offset(0, -42),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 440,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: _buildLoginCard(auth),
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: _buildSecurityFooter(),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 286),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.paddingOf(context).top + 26,
        24,
        74,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[_primaryRed, _deepRed],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(left: -54, top: 4, child: _buildGlowCircle(142, 0.08)),
          Positioned(
            right: -40,
            bottom: -72,
            child: _buildGlowCircle(178, 0.07),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.95),
                    width: 2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _darkRed.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.temple_hindu_rounded,
                  color: _gold,
                  size: 46,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Durga Puja Pandal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      color: _darkRed,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ADMIN CONTROL PANEL',
                      style: TextStyle(
                        color: _darkRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLoginCard(AuthController auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 23),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _gold.withValues(alpha: 0.65)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _darkRed.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Administrator Sign In',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _darkText,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Sign in with your authorised administrator account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText, fontSize: 13.5, height: 1.45),
          ),
          const SizedBox(height: 20),
          _buildAdminWarning(),
          const SizedBox(height: 23),
          _buildFieldLabel('Admin email'),
          const SizedBox(height: 8),
          _buildEmailField(),
          const SizedBox(height: 17),
          _buildFieldLabel('Password'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () {
                      Get.toNamed('/forgot-password');
                    },
              style: TextButton.styleFrom(
                foregroundColor: _deepRed,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLoginButton(auth),
        ],
      ),
    );
  }

  Widget _buildAdminWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _primaryRed.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryRed.withValues(alpha: 0.19)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _WarningIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ADMIN ACCESS ONLY',
                  style: TextStyle(
                    color: _deepRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This portal is restricted to authorised administrators. '
                  'Public users should not attempt to sign in.',
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _darkText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.email,
      autofillHints: const <String>[AutofillHints.email],
      autocorrect: false,
      style: const TextStyle(
        color: _darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDecoration(
        hintText: 'admin@example.com',
        prefixIcon: Icons.alternate_email_rounded,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      textInputAction: TextInputAction.done,
      validator: Validators.password,
      autofillHints: const <String>[AutofillHints.password],
      style: const TextStyle(
        color: _darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDecoration(
        hintText: 'Enter your password',
        prefixIcon: Icons.lock_outline_rounded,
        suffixIcon: IconButton(
          tooltip: _passwordVisible ? 'Hide password' : 'Show password',
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          icon: Icon(
            _passwordVisible
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: _mutedText,
            size: 21,
          ),
        ),
      ),
      onFieldSubmitted: (_) {
        _submit();
      },
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFAD9D98),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(prefixIcon, color: _deepRed, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _cream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(const Color(0xFFE8D9CB)),
      focusedBorder: border(_primaryRed, 1.5),
      errorBorder: border(_primaryRed),
      focusedErrorBorder: border(_primaryRed, 1.5),
      errorMaxLines: 2,
    );
  }

  Widget _buildLoginButton(AuthController auth) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: auth.isLoading ? 0.72 : 1,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[_primaryRed, _deepRed],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _deepRed.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: auth.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: auth.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.login_rounded, size: 20),
                    SizedBox(width: 9),
                    Text(
                      'Sign In to Dashboard',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.verified_user_outlined,
            size: 17,
            color: Color(0xFF9B7F74),
          ),
          SizedBox(width: 7),
          Flexible(
            child: Text(
              'Protected access for authorised administrators',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9B7F74),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningIcon extends StatelessWidget {
  const _WarningIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _LoginScreenState._primaryRed.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.gpp_maybe_rounded,
        size: 19,
        color: _LoginScreenState._deepRed,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/api_config_notifier.dart';
import '../../core/auth_session_notifier.dart';
import '../../core/theme.dart';
import 'api_base_url_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showEmailForm = false;

  AuthSessionNotifier get _auth => AuthSessionNotifier.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([
            _auth,
            ApiConfigNotifier.instance,
          ]),
          builder: (context, _) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Bantera',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displayLarge?.copyWith(
                                color: BanteraTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Language practice, cue by cue.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 32),

                            // ── Apple button (always visible) ──────────────
                            FutureBuilder<bool>(
                              future: SignInWithApple.isAvailable(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 50,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.data != true) {
                                  return Text(
                                    'Sign in with Apple is unavailable on this device.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  );
                                }
                                return SignInWithAppleButton(
                                  onPressed: _auth.isBusy
                                      ? null
                                      : () => _auth.continueWithApple(),
                                  text: 'Continue with Apple',
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                );
                              },
                            ),

                            // ── Email sign-in (expandable) ─────────────────
                            if (_showEmailForm) ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'or sign in with email',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(Icons.mail_outline),
                                      ),
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock_outline),
                                      ),
                                      validator: _validatePassword,
                                      onFieldSubmitted: (_) => _submit(),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed:
                                            _auth.isBusy ? null : _submit,
                                        child: Text(
                                          _auth.isBusy
                                              ? 'Signing in...'
                                              : 'Sign In',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _auth.isBusy
                                    ? null
                                    : () {
                                        setState(() => _showEmailForm = true);
                                        _auth.clearError();
                                      },
                                child: const Text('Sign in with email'),
                              ),
                            ],

                            // ── Error message ──────────────────────────────
                            if (_auth.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  _auth.errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: _auth.isBusy
                                  ? null
                                  : () async {
                                      final changed =
                                          await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ApiBaseUrlScreen(),
                                        ),
                                      );
                                      if (changed == true) _auth.clearError();
                                    },
                              icon: const Icon(Icons.link, size: 16),
                              label: Text(
                                'API: ${ApiConfigNotifier.instance.baseUrl}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
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
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your email.';
    if (!trimmed.contains('@')) return 'Enter a valid email.';
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'Enter your password.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _auth.clearError();
    if (!_formKey.currentState!.validate()) return;
    await _auth.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}

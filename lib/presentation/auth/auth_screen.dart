import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/auth_session_notifier.dart';
import '../../core/theme.dart';
import '../../infrastructure/network_reachability.dart';
import '../../l10n/app_localizations.dart';
import 'api_base_url_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showEmailForm = false;
  int _logoTapCount = 0;
  DateTime? _lastLogoTap;

  /// iOS: true when local Wi‑Fi/cellular policy suggests Bantera cannot reach the network.
  bool _proactiveCellularBlocked = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  AuthSessionNotifier get _auth => AuthSessionNotifier.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreCredentials();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      _refreshProactiveNetworkHint();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProactiveNetworkHint();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshProactiveNetworkHint();
    }
  }

  Future<void> _refreshProactiveNetworkHint() async {
    if (!Platform.isIOS) {
      if (_proactiveCellularBlocked && mounted) {
        setState(() => _proactiveCellularBlocked = false);
      }
      return;
    }
    final kind = await NetworkReachability.classifyLocalConnectivity();
    if (!mounted) return;
    final blocked = kind == NetworkIssueKind.cellularBlockedNoWifi;
    if (blocked != _proactiveCellularBlocked) {
      setState(() => _proactiveCellularBlocked = blocked);
    }
  }

  static Future<File> get _credentialsFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/saved_credentials.json');
  }

  Future<void> _restoreCredentials() async {
    try {
      final file = await _credentialsFile;
      if (await file.exists()) {
        final raw = await file.readAsString();
        if (raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            final email = decoded['email'] as String? ?? '';
            final password = decoded['password'] as String? ?? '';
            if (email.isNotEmpty && mounted) {
              _emailController.text = email;
              _passwordController.text = password;
            }
          }
        }
      }
    } catch (_) {}
  }

  static Future<void> _saveCredentials(String email, String password) async {
    try {
      final file = await _credentialsFile;
      await file.writeAsString(jsonEncode({
        'email': email,
        'password': password,
      }));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _auth,
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
                            GestureDetector(
                              onTap: () {
                                final now = DateTime.now();
                                if (_lastLogoTap == null ||
                                    now.difference(_lastLogoTap!) >
                                        const Duration(seconds: 3)) {
                                  _logoTapCount = 1;
                                } else {
                                  _logoTapCount++;
                                }
                                _lastLogoTap = now;
                                if (_logoTapCount >= 16) {
                                  _logoTapCount = 0;
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const ApiBaseUrlScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                l10n.appName,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displayLarge?.copyWith(
                                  color: BanteraTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.appTagline,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 32),

                            // ── Proactive network hint (iOS, local only; no API call) ──
                            if (_proactiveCellularBlocked &&
                                _auth.authApiError?.code !=
                                    'network_cellular_blocked') ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.orange.shade800,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        l10n.errorNetworkCellularBlocked,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

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
                                    l10n.authAppleUnavailable,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  );
                                }
                                return SignInWithAppleButton(
                                  onPressed: _auth.isBusy
                                      ? null
                                      : () => _auth.continueWithApple(),
                                  text: l10n.authContinueWithApple,
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
                                      l10n.authOrSignInEmail,
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
                                      decoration: InputDecoration(
                                        labelText: l10n.authEmail,
                                        prefixIcon: const Icon(Icons.mail_outline),
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
                                      decoration: InputDecoration(
                                        labelText: l10n.authPassword,
                                        prefixIcon: const Icon(Icons.lock_outline),
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
                                              ? l10n.authSigningIn
                                              : l10n.authSignIn,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // ── Error message ──────────────────────────────
                            if (_auth.localizedError(l10n) != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  _auth.localizedError(l10n)!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],

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
    final l10n = AppLocalizations.of(context)!;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.validationEnterEmail;
    if (!trimmed.contains('@')) return l10n.validationValidEmail;
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if ((value ?? '').isEmpty) return l10n.validationEnterPassword;
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _auth.clearError();
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    await _auth.loginWithEmail(email: email, password: password);
    if (_auth.isAuthenticated) {
      _saveCredentials(email, password);
    }
  }
}

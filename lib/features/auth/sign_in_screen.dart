import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/haptics.dart';
import '../../core/design/icons.dart';
import '../../core/design/palette.dart';
import '../../core/design/tokens.dart';
import '../../core/widgets/aurora.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/fields.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/logo.dart';
import '../../core/widgets/toast.dart';
import '../../data/providers.dart';
import '../../data/repositories/auth_repository.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _emailMode = false;
  String? _busy;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(String key, Future<void> Function() action) async {
    setState(() => _busy = key);
    try {
      await action();
      Haptics.success();
    } on AuthFailure catch (e) {
      if (e.message != 'Cancelled' && mounted) showToast(context, e.message, error: true);
    } catch (e) {
      if (mounted) showToast(context, 'Sign-in failed', error: true);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authRepositoryProvider);
    final p = context.palette;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: Aurora()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Gaps.x6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      const LogoMark(size: 96)
                          .animate()
                          .scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.easeOutBack)
                          .then()
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -5, duration: 2200.ms, curve: Curves.easeInOut),
                      const SizedBox(height: Gaps.x5),
                      Text('Arnav Chat', style: context.text.displaySmall)
                          .animate()
                          .fadeIn(delay: 120.ms)
                          .moveY(begin: 10, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: Gaps.x10),
                      Glass(
                        radius: Radii.xl,
                        padding: const EdgeInsets.all(Gaps.x4),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              PillButton(
                                label: 'Continue with Google',
                                icon: AppIcons.google,
                                style: PillStyle.primary,
                                busy: _busy == 'google',
                                onPressed: _busy != null ? null : () => _run('google', auth.signInWithGoogle),
                              ),
                              const SizedBox(height: Gaps.x3),
                              if (!_emailMode)
                                PillButton(
                                  label: 'Email',
                                  icon: AppIcons.mail,
                                  style: PillStyle.ghost,
                                  onPressed: () => setState(() => _emailMode = true),
                                )
                              else ...[
                                PillField(
                                  controller: _email,
                                  hint: 'Email',
                                  icon: AppIcons.mail,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  autofocus: true,
                                ),
                                const SizedBox(height: Gaps.x3),
                                PillField(
                                  controller: _password,
                                  hint: 'Password',
                                  icon: AppIcons.lock,
                                  obscure: true,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onSubmitted: (_) => _submitEmail(auth),
                                ),
                                const SizedBox(height: Gaps.x3),
                                PillButton(
                                  label: 'Continue',
                                  style: PillStyle.secondary,
                                  busy: _busy == 'email',
                                  onPressed: _busy != null ? null : () => _submitEmail(auth),
                                ),
                                PillButton(
                                  label: 'Forgot password',
                                  style: PillStyle.ghost,
                                  height: 44,
                                  onPressed: () async {
                                    if (_email.text.trim().isEmpty) return showToast(context, 'Enter email');
                                    await auth.sendPasswordReset(_email.text);
                                    if (context.mounted) showToast(context, 'Reset link sent');
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 220.ms, duration: 400.ms).moveY(begin: 24, end: 0, curve: Curves.easeOutCubic),
                      const SizedBox(height: Gaps.x6),
                      Icon(AppIcons.shield, size: 18, color: p.textFaint).animate().fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitEmail(AuthRepository auth) {
    if (_email.text.trim().isEmpty || _password.text.length < 6) {
      showToast(context, 'Password: 6+ characters', error: true);
      return;
    }
    _run('email', () => auth.signInWithEmail(_email.text, _password.text));
  }
}

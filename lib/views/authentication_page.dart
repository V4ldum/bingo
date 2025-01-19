import 'package:bingo/router.dart';
import 'package:bingo/view_models/authentication_view_model.dart';
import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rust/rust.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final obscuredPasswordProvider = StateProvider<bool>((ref) => true);

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode passwordFocusNode = FocusNode();

  Future<void> _onAuthenticateButtonPressed(BuildContext context, WidgetRef ref) async {
    final authenticated = await ref.read(authenticationViewModelProvider.notifier).authenticate();

    if (authenticated == null) {
      // Did not send a request, skip
      return;
    }
    if (context.mounted) {
      if (authenticated) {
        // We pass a value here to force the route to rebuild, not ideal but don't know
        // how to do otherwise
        context.goNamed(AppRoutes.admin, extra: true);
      } else {
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text("Nom d'utilisateur ou mot de passe incorrect"),
          ),
        );
      }
    }
  }

  Widget _authenticationForm() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Connexion',
              style: ShadTheme.of(context).textTheme.h3,
            ),
          ),
          const SizedBox(height: 30),
          ShadInput(
            controller: usernameController,
            placeholder: const Text("Nom d'utilisateur"),
            autocorrect: false,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            onChanged: ref.read(authenticationViewModelProvider.notifier).onUsernameChanged,
          ),
          const SizedBox(height: 10),
          ShadInput(
            focusNode: passwordFocusNode,
            controller: passwordController,
            placeholder: const Text('Mot de passe'),
            autocorrect: false,
            obscureText: ref.watch(obscuredPasswordProvider),
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onChanged: ref.read(authenticationViewModelProvider.notifier).onPasswordChanged,
            obscuringCharacter: '●',
            suffix: ShadButton.ghost(
              width: 24,
              height: 24,
              padding: EdgeInsets.zero,
              decoration: const ShadDecoration(
                secondaryBorder: ShadBorder.none,
                secondaryFocusedBorder: ShadBorder.none,
              ),
              onPressed: () => ref.read(obscuredPasswordProvider.notifier).state =
                  !ref.read(obscuredPasswordProvider.notifier).state,
              icon: Icon(
                size: 16,
                ref.read(obscuredPasswordProvider) ? LucideIcons.eye : LucideIcons.eyeOff,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ShadButton(
            enabled: !ref.watch(authenticationViewModelProvider).isLoading,
            onPressed: () => _onAuthenticateButtonPressed(context, ref),
            icon: ref.read(authenticationViewModelProvider).isLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hack to get password managers to work with Flutter Web
    final value = Option.of(ref.read(authenticationViewModelProvider).valueOrNull);
    if (value case Some(:final v)) {
      if (usernameController.text != v.$1) {
        debugPrint('Username field is desync-ed, probably means something autofilled, fixing');
        usernameController.text = ref.read(authenticationViewModelProvider).value?.$1 ?? '';
      }
      if (passwordController.text != v.$2) {
        debugPrint('Password field is desync-ed, probably means something autofilled, fixing');
        passwordController.text = ref.read(authenticationViewModelProvider).value?.$2 ?? '';
        passwordFocusNode.requestFocus();
        passwordController.selection = TextSelection.fromPosition(TextPosition(offset: passwordController.text.length));
      }
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: ShadResponsiveBuilder(
          builder: (context, breakpoint) {
            if (breakpoint == ShadTheme.of(context).breakpoints.tn) {
              return Padding(
                padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
                child: _authenticationForm(),
              );
            }
            return ShadCard(
              width: 350,
              child: _authenticationForm(),
            );
          },
        ),
      ),
    );
  }
}

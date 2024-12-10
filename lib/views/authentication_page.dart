import 'package:bingo/router.dart';
import 'package:bingo/view_models/authentication_view_model.dart';
import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final obscuredPasswordProvider = StateProvider<bool>((ref) => true);

class AuthenticationPage extends ConsumerWidget {
  const AuthenticationPage({super.key});

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
        context.goNamed(AppRoute.admin, extra: true);
      } else {
        ShadToaster.of(context).show(
          const ShadToast(
            description: Text("Nom d'utilisateur ou mot de passe incorrect"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController()
      ..text = ref.read(authenticationViewModelProvider).value?.$1 ?? '';
    final passwordController = TextEditingController()
      ..text = ref.read(authenticationViewModelProvider).value?.$2 ?? '';

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: ShadCard(
          width: 350,
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
                onChanged: ref.read(authenticationViewModelProvider.notifier).onUsernameChanged,
              ),
              const SizedBox(height: 10),
              ShadInput(
                controller: passwordController,
                placeholder: const Text('Mot de passe'),
                autocorrect: false,
                obscureText: ref.watch(obscuredPasswordProvider),
                textInputAction: TextInputAction.done,
                onChanged: ref.read(authenticationViewModelProvider.notifier).onPasswordChanged,
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
        ),
      ),
    );
  }
}

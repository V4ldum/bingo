import 'dart:async';

import 'package:bingo/repositories/database_repository.dart';
import 'package:bingo/utils/native_inputs.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '_generated/authentication_view_model.g.dart';

@riverpod
class AuthenticationViewModel extends _$AuthenticationViewModel {
  @override
  Future<(String, String)> build() async {
    if (kIsWeb) {
      // Attach native input fields to the HTML DOM to make password managers work
      NativeInputs.attach(usernameCallback: onUsernameChanged, passwordCallback: onPasswordChanged);
      ref.onDispose(NativeInputs.dispose);
    }
    return Future.value(('', ''));
  }

  void onUsernameChanged(String value) {
    if (state.hasValue && value != state.requireValue.$1) {
      state = AsyncData((value, state.requireValue.$2));
    }
  }

  void onPasswordChanged(String value) {
    if (state.hasValue && value != state.requireValue.$2) {
      state = AsyncData((state.requireValue.$1, value));
    }
  }

  Future<bool?> authenticate() async {
    if (!state.hasValue) {
      return null;
    }
    if (state.requireValue.$1.isEmpty || state.requireValue.$2.isEmpty) {
      return false;
    }

    late final bool ret;
    final oldState = state.requireValue;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      ret = await ref.read(databaseRepositoryProvider).authenticateUser(state.requireValue.$1, state.requireValue.$2);
      return oldState;
    });

    return ret;
  }

  bool isAuthenticated() {
    return ref.read(databaseRepositoryProvider).isAuthenticated();
  }
}

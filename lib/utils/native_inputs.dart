import 'dart:html' as html;

import 'package:flutter/foundation.dart';

class NativeInputs {
  NativeInputs._();

  static const kUsernameFieldId = '#native-username-field';
  static const kPasswordFieldId = '#native-password-field';

  static void attach({void Function(String)? usernameCallback, void Function(String)? passwordCallback}) {
    _attachUsernameField(usernameCallback);
    _attachPasswordField(passwordCallback);
  }

  static void _attachUsernameField(void Function(String)? usernameCallback) {
    // Add an username field if it does not already exist
    if (html.document.querySelector(kUsernameFieldId) == null) {
      final usernameInput = html.InputElement()
        ..id = kUsernameFieldId
        ..type = 'text'
        ..name = 'username';

      // Style the input depending of debug mode
      if (kDebugMode) {
        // show the fields in debug
        usernameInput.style
          ..position = 'absolute'
          ..top = '100px'
          ..left = '50px';
      } else {
        // hide the fields in release
        usernameInput.style
          ..position = 'absolute'
          ..top = '-100px'
          ..left = '-100px'
          ..width = '1px'
          ..height = '1px'
          ..opacity = '0';
      }

      html.document.body?.append(usernameInput);

      // Unfocus it ASAP
      usernameInput.onFocus.listen((_) => usernameInput.blur());
      usernameInput.onInput.listen((event) {
        usernameCallback?.call(usernameInput.value ?? '');
      });
    }
  }

  static void _attachPasswordField(void Function(String)? passwordCallback) {
    // Add a password field if it does not already exist
    if (html.document.querySelector(kPasswordFieldId) == null) {
      final passwordInput = html.InputElement()
        ..id = kPasswordFieldId
        ..type = 'password'
        ..name = 'password';

      // Style the input depending of debug mode
      if (kDebugMode) {
        // show the fields in debug
        passwordInput.style
          ..position = 'absolute'
          ..top = '125px'
          ..left = '50px';
      } else {
        // hide the fields in release
        passwordInput.style
          ..position = 'absolute'
          ..top = '-100px'
          ..left = '-100px'
          ..width = '1px'
          ..height = '1px'
          ..opacity = '0';
      }

      html.document.body?.append(passwordInput);

      // Unfocus it ASAP
      passwordInput.onFocus.listen((_) => passwordInput.blur());
      passwordInput.onInput.listen((_) {
        passwordCallback?.call(passwordInput.value ?? '');
      });
    }
  }

  static void dispose() {
    html.document.querySelector(kUsernameFieldId)?.remove();
    html.document.querySelector(kPasswordFieldId)?.remove();
  }
}

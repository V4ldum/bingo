import 'package:bingo/views/authentication_page.dart';
import 'package:bingo/views/bingo_edit_page.dart';
import 'package:bingo/views/bingo_page.dart';
import 'package:bingo/views/list_page.dart';
import 'package:bingo/views/not_found_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@protected
final router = GoRouter(
  initialLocation: AppRoute._adminPath,
  errorBuilder: (_, __) => const NotFoundPage(),
  redirect: (_, state) {
    final guard = [AppRoute._bingoNewPath, AppRoute._bingoEditPath];
    final authenticated = Supabase.instance.client.auth.currentSession != null;

    if (guard.contains(state.fullPath) && !authenticated) {
      return AppRoute._adminPath;
    }
    return null;
  },
  routes: [
    GoRoute(
      name: AppRoute.admin,
      path: AppRoute._adminPath,
      builder: (_, __) {
        final authenticated = Supabase.instance.client.auth.currentSession != null;

        if (!authenticated) {
          return const AuthenticationPage();
        }
        return const ListPage();
      },
    ),
    GoRoute(
      name: AppRoute.bingo,
      path: AppRoute._bingoPath,
      builder: (_, state) => BingoPage(id: state.pathParameters['id']!),
    ),
    GoRoute(
      name: AppRoute.bingoEdit,
      path: AppRoute._bingoEditPath,
      builder: (_, state) => BingoEditPage(id: state.pathParameters['id']),
    ),
    GoRoute(
      name: AppRoute.bingoNew,
      path: AppRoute._bingoNewPath,
      builder: (_, __) => const BingoEditPage(),
    ),
  ],
);

class AppRoute {
  AppRoute._();

  static const String admin = 'admin';
  static const String _adminPath = '/';

  static const String bingoNew = 'bingoNew';
  static const String _bingoNewPath = '/new';

  static const String bingoEdit = 'bingoEdit';
  static const String _bingoEditPath = '/edit/:id';

  static const String bingo = 'bingo';
  static const String _bingoPath = '/bingo/:id';
}

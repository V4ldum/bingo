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
  initialLocation: AppRoutes._adminPath,
  errorBuilder: (_, _) => const NotFoundPage(),
  redirect: (_, state) {
    final guard = [AppRoutes._bingoNewPath, AppRoutes._bingoEditPath];
    final authenticated = Supabase.instance.client.auth.currentSession != null;

    if (guard.contains(state.fullPath) && !authenticated) {
      return AppRoutes._adminPath;
    }
    return null;
  },
  routes: [
    GoRoute(
      name: AppRoutes.admin,
      path: AppRoutes._adminPath,
      builder: (_, _) {
        final authenticated = Supabase.instance.client.auth.currentSession != null;

        if (!authenticated) {
          return const AuthenticationPage();
        }
        return const ListPage();
      },
    ),
    GoRoute(
      name: AppRoutes.bingo,
      path: AppRoutes._bingoPath,
      builder: (_, state) => BingoPage(id: state.pathParameters['id']!),
    ),
    GoRoute(
      name: AppRoutes.bingoEdit,
      path: AppRoutes._bingoEditPath,
      builder: (_, state) => BingoEditPage(id: state.pathParameters['id']),
    ),
    GoRoute(
      name: AppRoutes.bingoNew,
      path: AppRoutes._bingoNewPath,
      builder: (_, _) => const BingoEditPage(),
    ),
  ],
);

class AppRoutes {
  AppRoutes._();

  static const String admin = 'admin';
  static const String _adminPath = '/';

  static const String bingoNew = 'bingoNew';
  static const String _bingoNewPath = '/new';

  static const String bingoEdit = 'bingoEdit';
  static const String _bingoEditPath = '/edit/:id';

  static const String bingo = 'bingo';
  static const String _bingoPath = '/bingo/:id';
}

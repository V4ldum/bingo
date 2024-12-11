import 'dart:async';

import 'package:bingo/models/bingo.dart';
import 'package:bingo/repositories/database_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rust/rust.dart';

part '_generated/bingo_list_view_model.g.dart';

@riverpod
class BingoListViewModel extends _$BingoListViewModel {
  @override
  Future<Vec<Bingo>> build() async => (await ref.read(databaseRepositoryProvider).getAllBingos())
    ..sort(
      // Latest first
      (a, b) => b.created.compareTo(a.created),
    );

  void deleteBingo(String id) {
    if (state.hasValue) {
      state = AsyncData([
        ...state.requireValue..removeWhere((element) => element.id == id),
      ]);
      unawaited(ref.read(databaseRepositoryProvider).deleteBingo(id));
    }
  }
}

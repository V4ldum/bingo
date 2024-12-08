import 'package:bingo/models/bingo.dart';
import 'package:bingo/repositories/database_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rust/option.dart';

part '_generated/bingo_view_model.g.dart';

@riverpod
class BingoViewModel extends _$BingoViewModel {
  @override
  Future<Bingo> build(String id) async {
    _enableDatabaseRealtimeUpdates(id);
    return ref.read(databaseRepositoryProvider).getBingo(id: id);
  }

  void checkBingoItem(String id) {
    final value = Option.from(state.valueOrNull);

    if (value case Some(:final v)) {
      final item = Option.from(v.items.where((item) => item.id == id).firstOrNull);

      if (item case Some(:final v)) {
        ref.read(databaseRepositoryProvider).checkBingoItem(id, isChecked: !v.isChecked);
      }
    }
  }

  void _enableDatabaseRealtimeUpdates(String bingoId) {
    debugPrint("Enabling realtime updates for the bingo '$bingoId'");
    ref.read(databaseRepositoryProvider).subscribeToRealtimeUpdates(
          bingoId: bingoId,
          callback: (newItem) => _realtimeUpdateRebuild(BingoItem.fromDto(newItem)),
        );

    ref.onDispose(() {
      debugPrint("Disabling realtime updates for the bingo '$bingoId'");
      ref.read(databaseRepositoryProvider).stopRealtimeUpdates();
    });
  }

  void _realtimeUpdateRebuild(BingoItem newItem) {
    final value = Option.from(state.valueOrNull);

    if (value case Some(:final v)) {
      final oldItemIndex = v.items.indexWhere((item) => item.id == newItem.id);

      // index found
      if (oldItemIndex > -1) {
        // update old item
        state.requireValue.items[oldItemIndex] = newItem;
        // force refresh
        state = AsyncData(state.requireValue);
      }
    }
  }
}

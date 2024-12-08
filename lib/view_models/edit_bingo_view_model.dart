import 'package:bingo/models/bingo.dart';
import 'package:bingo/repositories/database_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rust/ops.dart';

part '_generated/edit_bingo_view_model.g.dart';

@riverpod
class EditBingoViewModel extends _$EditBingoViewModel {
  @override
  Future<Bingo> build({String? id}) async {
    if (id == null) {
      return Bingo(id: '', title: '', size: 4, created: DateTime.now());
    }
    return ref.read(databaseRepositoryProvider).getBingo(id: id);
  }

  Future<void> editBingo() async {
    final oldState = state.requireValue;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      id == null
          ? await ref.read(databaseRepositoryProvider).createBingo(state.requireValue)
          : await ref.read(databaseRepositoryProvider).updateBingo(state.requireValue);

      return oldState;
    });
  }

  void shuffle() {
    // Copy and shuffle indexes
    final indexes = state.requireValue.items.map((item) => item.index).toList()..shuffle();
    // Copy items
    final items = state.requireValue.items.toList();

    // Update cells then sort
    for (final i in Range(0, items.length)) {
      items[i] = items[i].copyWith(index: indexes[i]);
    }
    items.sort((a, b) => a.index.compareTo(b.index));

    state = const AsyncLoading();
    state = AsyncData(state.requireValue.copyWith(items: items));
  }

  void size(int value) {
    if (state.requireValue.size != value) {
      state = AsyncData(state.requireValue.copyWith(size: value));
    }
  }

  void title(String value) {
    if (state.requireValue.title != value) {
      state = AsyncData(state.requireValue.copyWith(title: value));
    }
  }

  void cell({required String value, required int index}) {
    // No need to rebuild, done on purpose
    state.requireValue.items[index] = state.requireValue.items[index].copyWith(text: value);
  }
}

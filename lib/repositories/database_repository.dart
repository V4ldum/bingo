import 'package:bingo/models/bingo.dart';
import 'package:bingo/repositories/dtos/bingo_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part '_generated/database_repository.g.dart';

@riverpod
DatabaseRepository databaseRepository(Ref ref) {
  return DatabaseRepository();
}

class DatabaseRepository {
  final _client = Supabase.instance.client;

  static const _kBingoTableName = 'bingo';
  static const _kBingoItemTableName = 'bingo_item';

  static const _kBingoIdColumnName = 'id';
  static const _kBingoTitleColumnName = 'title';
  static const _kBingoSizeColumnName = 'size';
  static const _kBingoCreatedColumnName = 'created';

  static const _kBingoItemIdColumnName = 'id';
  static const _kBingoItemTextColumnName = 'text';
  static const _kBingoItemIsCheckedColumnName = 'is_checked';
  static const _kBingoItemIndexColumnName = 'index';
  static const _kBingoItemBingoIdColumnName = 'bingo_id';

  Future<Bingo> getBingo({required String id}) async {
    final bingo = await _client.from(_kBingoTableName).select().eq(_kBingoIdColumnName, id);
    final items = await _client.from(_kBingoItemTableName).select().eq(_kBingoItemBingoIdColumnName, id);

    final dto = BingoDto.fromJson({...bingo.first, 'items': items});

    return Bingo.fromDto(dto);
  }

  Future<List<Bingo>> getAllBingos() async {
    final bingos = await _client.from(_kBingoTableName).select();
    final dtos = bingos.map(BingoDto.fromJson);

    return dtos.map(Bingo.fromDto).toList();
  }

  Future<String> createBingo(Bingo bingo) async {
    final res = await _client.from(_kBingoTableName).insert({
      _kBingoTitleColumnName: bingo.title,
      _kBingoSizeColumnName: bingo.size,
      _kBingoCreatedColumnName: DateFormat('MM-dd-yyyy').format(bingo.created), // american spergs
    }).select();
    final newBingo = BingoDto.fromJson(res.first);

    for (final item in bingo.items) {
      await _client.from(_kBingoItemTableName).insert({
        _kBingoItemTextColumnName: item.text,
        _kBingoItemIndexColumnName: item.index,
        _kBingoItemBingoIdColumnName: newBingo.id,
      });
    }

    return newBingo.id;
  }

  Future<void> updateBingo(Bingo bingo) async {
    await _client
        .from(_kBingoTableName)
        .update({
          _kBingoTitleColumnName: bingo.title,
          _kBingoSizeColumnName: bingo.size,
          _kBingoCreatedColumnName: DateFormat('MM-dd-yyyy').format(bingo.created), // american spergs
        })
        .eq(_kBingoIdColumnName, bingo.id);

    for (final item in bingo.items) {
      await _client
          .from(_kBingoItemTableName)
          .update({
            _kBingoItemTextColumnName: item.text,
            _kBingoItemIndexColumnName: item.index,
          })
          .eq(_kBingoItemIdColumnName, item.id);
    }
  }

  Future<void> checkBingoItem(String bingoItemId, {required bool isChecked}) async {
    await _client
        .from(_kBingoItemTableName)
        .update({_kBingoItemIsCheckedColumnName: isChecked})
        .eq(_kBingoItemIdColumnName, bingoItemId);
  }

  Future<void> deleteBingo(String id) async {
    await _client.from(_kBingoItemTableName).delete().eq(_kBingoItemBingoIdColumnName, id);
    await _client.from(_kBingoTableName).delete().eq(_kBingoIdColumnName, id);
  }

  Future<bool> authenticateUser(String username, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: '$username@noemail.com',
        password: password,
      );
    } catch (e) {
      return false;
    }
    return true;
  }

  void subscribeToRealtimeUpdates({required String bingoId, required void Function(BingoItemDto) callback}) {
    _client
        .channel('public:bingo_item')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _kBingoItemTableName,
          callback: (payload) => callback(BingoItemDto.fromJson(payload.newRecord)),
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: _kBingoItemBingoIdColumnName,
            value: bingoId,
          ),
        )
        .subscribe();
  }

  void stopRealtimeUpdates() {
    _client.removeAllChannels();
  }
}

import 'package:bingo/repositories/dtos/bingo_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:rust/ops.dart';
import 'package:rust/vec.dart';

Vec<BingoItem> _processBingoItems({required int size, required Vec<BingoItem> vec}) {
  vec.sort((a, b) => a.index.compareTo(b.index));
  size = size * size;

  if (vec.length != size) {
    vec.resize(size, BingoItem(id: '', text: '', index: 0));
  }

  // update indexes
  for (final i in Range(0, vec.length)) {
    if (vec[i].index != i) {
      vec[i] = vec[i].copyWith(index: i);
    }
  }

  return vec;
}

class Bingo {
  Bingo({
    required this.id,
    required this.title,
    required this.size,
    required this.created,
    Vec<BingoItem>? items,
  }) : items = _processBingoItems(size: size, vec: items ?? Vec.empty(growable: true));

  factory Bingo.fromDto(BingoDto dto) {
    if (kDebugMode) {
      final size = dto.size * dto.size;
      // if 0 it means we're on the list page, skipping
      if (size != dto.items.length && dto.items.isNotEmpty) {
        debugPrint(
          'WARNING: Bingo ${dto.id} has an inconsistent size : size is $size and number of items is ${dto.items.length}',
        );
      }
    }

    return Bingo(
      id: dto.id,
      title: dto.title,
      size: dto.size,
      created: dto.created,
      items: dto.items.map(BingoItem.fromDto).toVec(),
    );
  }

  final String id;
  final String title;
  final int size; // size x size
  final DateTime created;
  final Vec<BingoItem> items;

  Bingo copyWith({
    String? id,
    String? title,
    int? size,
    DateTime? created,
    Vec<BingoItem>? items,
  }) {
    return Bingo(
      id: id ?? this.id,
      title: title ?? this.title,
      size: size ?? this.size,
      created: created ?? this.created,
      items: items ?? this.items,
    );
  }
}

class BingoItem {
  BingoItem({
    required this.id,
    required this.index,
    required this.text,
    this.isChecked = false,
  });

  factory BingoItem.fromDto(BingoItemDto dto) {
    return BingoItem(
      id: dto.id,
      index: dto.index,
      text: dto.text,
      isChecked: dto.isChecked,
    );
  }

  final String id;
  final int index;
  final String text;
  final bool isChecked;

  BingoItem copyWith({
    String? id,
    int? index,
    String? text,
    bool? isChecked,
  }) {
    return BingoItem(
      id: id ?? this.id,
      index: index ?? this.index,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

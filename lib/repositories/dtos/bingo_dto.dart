import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta_package/meta_package.dart';
import 'package:rust/rust.dart';

part '_generated/bingo_dto.freezed.dart';
part '_generated/bingo_dto.g.dart';

@freezed
sealed class BingoDto with _$BingoDto {
  const factory BingoDto({
    required String id,
    required String title,
    required int size,
    required DateTime created,
    @JsonKey(defaultValue: []) required Vec<BingoItemDto> items,
  }) = _BingoDto;

  factory BingoDto.fromJson(JsonMapResponse json) => _$BingoDtoFromJson(json);
}

@freezed
sealed class BingoItemDto with _$BingoItemDto {
  const factory BingoItemDto({
    required String id,
    @JsonKey(defaultValue: 0) required int index,
    required String text,
    @JsonKey(name: 'is_checked') required bool isChecked,
  }) = _BingoItemDto;

  factory BingoItemDto.fromJson(JsonMapResponse json) => _$BingoItemDtoFromJson(json);
}

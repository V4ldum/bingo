import 'dart:typed_data';
import 'dart:ui';

import 'package:bingo/models/bingo.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:rust/rust.dart';

class ImageDownloader {
  ImageDownloader._();

  static final downloadKey = GlobalKey();

  static Future<bool> downloadAsImage(Bingo bingo) async {
    final res = await Option.async<Uint8List>(($) async {
      final currentContext = Option.of(downloadKey.currentContext)[$]; // returns early if null
      final renderObject =
          Option.of(currentContext.findRenderObject() as RenderRepaintBoundary?)[$]; // returns early if null

      final image = await renderObject.toImage();
      final byteData = Option.of(await image.toByteData(format: ImageByteFormat.png))[$]; // returns early if null
      final pngBytes = byteData.buffer.asUint8List();

      return Some(pngBytes);
    });

    if (res case Some(:final v)) {
      return guard(
        () async => WebImageDownloader.downloadImageFromUInt8List(
          uInt8List: v,
          name: bingo.title.replaceAll(RegExp(r'[\/ ]'), '-').toLowerCase(),
        ),
      ).map((_) => true).unwrapOr(false);
    }
    return false;
  }
}

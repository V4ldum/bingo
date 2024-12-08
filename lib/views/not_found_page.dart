import 'package:bingo/widgets/custom_app_bar.dart';
import 'package:bingo/widgets/no_bingo_here_error.dart';
import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.only(top: 40),
        child: NoBingoHereError(error: null, trace: null),
      ),
    );
  }
}

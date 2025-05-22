/*
 *     Discipulus
 *     Copyright (C) 2025  Sam Wagenaar
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/s.dart';
import 'package:discipulus/widgets/debug_tree_display.dart';
import 'package:flutter/material.dart';

class TranslationTreeScreen extends StatelessWidget {
  final Pair<String, S> sentence;

  const TranslationTreeScreen({
    super.key,
    required this.sentence
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(
          sentence.second.translate(null),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SingleChildScrollView(
        child: Center(
          child: ANSIText(text: sentence.first),
        ),
      ),
    );
  }
}
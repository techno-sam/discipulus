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
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DebugTreeDisplay extends StatelessWidget {
  final TreeDebugNode debugNode;

  const DebugTreeDisplay({super.key, required this.debugNode});

  @override
  Widget build(BuildContext context) {
    final lines = TreeDebugNode.getDebugLines(debugNode);

    return ANSIText(text: lines.join("\n"));
  }
}

class ANSIText extends StatelessWidget {
  final String text;

  const ANSIText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RichText(
      text: TextSpan(
        children: _handleANSIColors(text),
        style: GoogleFonts.fragmentMonoTextTheme(theme.textTheme).bodyMedium,
      ),
    );
  }
}

List<InlineSpan> _handleANSIColors(String text) {
  final List<InlineSpan> out = [];
  final RegExp ansiRegex = RegExp(r'\x1B\[[0-9]+m');

  int lastIndex = 0;
  AnsiStyle currentStyle = const AnsiStyle();

  final List<Either<String, AnsiStyle>> tokens = [];

  for (final match in ansiRegex.allMatches(text)) {
    if (lastIndex < match.start) {
      tokens.add(Either.a(text.substring(lastIndex, match.start)));
    }

    final String ansiCode = match.group(0)!;
    final AnsiStyle newStyle = currentStyle.applyModifier(int.parse(ansiCode.substring(2, ansiCode.length - 1)));

    if (newStyle != currentStyle) {
      tokens.add(Either.b(newStyle));
      currentStyle = newStyle;
    }

    lastIndex = match.end;
  }

  if (lastIndex < text.length) {
    tokens.add(Either.a(text.substring(lastIndex)));
  }

  final mergedTokens = tokens.partialMerge((acc, v) {
    if (acc.isA && v.isA) {
      return Either.a(acc.a + v.a);
    }
    return null;
  });

  currentStyle = const AnsiStyle();

  for (final token in mergedTokens) {
    if (token.isA) {
      out.add(TextSpan(text: token.a, style: currentStyle.toTextStyle()));
    } else {
      currentStyle = token.b;
    }
  }

  return out;
}
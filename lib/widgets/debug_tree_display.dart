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

enum AnsiColor {
  BLACK(Colors.black),
  RED(Colors.red),
  GREEN(Colors.green),
  YELLOW(Colors.yellow),
  BLUE(Colors.blue),
  MAGENTA(Colors.purple),
  CYAN(Colors.cyan),
  WHITE(Colors.white),
  LIGHTBLACK_EX(Colors.black54),
  LIGHTRED_EX(Colors.redAccent),
  LIGHTGREEN_EX(Colors.greenAccent),
  LIGHTYELLOW_EX(Colors.yellowAccent),
  LIGHTBLUE_EX(Colors.blueAccent),
  LIGHTMAGENTA_EX(Colors.purpleAccent),
  LIGHTCYAN_EX(Colors.cyanAccent),
  LIGHTWHITE_EX(Colors.white70),
  ;

  final Color color;

  const AnsiColor(this.color);
}

class AnsiStyle {
  final AnsiColor? foreground;
  final AnsiColor? background;
  final bool bright;

  const AnsiStyle({this.foreground, this.background, this.bright = false});

  AnsiStyle copyWith({AnsiColor? foreground, AnsiColor? background, bool? bright}) {
    return AnsiStyle(
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      bright: bright ?? this.bright,
    );
  }

  AnsiStyle withForeground(AnsiColor? color) {
    return AnsiStyle(
      foreground: color,
      background: background,
      bright: bright,
    );
  }

  AnsiStyle withBackground(AnsiColor? color) {
    return AnsiStyle(
      foreground: foreground,
      background: color,
      bright: bright,
    );
  }

  AnsiStyle withBright(bool bright) {
    return AnsiStyle(
      foreground: foreground,
      background: background,
      bright: bright,
    );
  }

  AnsiStyle applyModifier(int modifier) {
    if (modifier == 0) { // reset all
      return const AnsiStyle();
    }

    // brightness
    if (modifier == 2 || modifier == 22) {
      return withBright(false);
    } else if (modifier == 1) {
      return withBright(true);
    }

    // foreground
    if (modifier == 39) { // reset
      return withForeground(null);
    } else if (modifier >= 30 && modifier <= 37) {
      return withForeground(AnsiColor.values[modifier - 30]);
    } else if (modifier >= 90 && modifier <= 97) {
      return withForeground(AnsiColor.values[modifier - 90 + 8]);
    }

    // background
    if (modifier == 49) { // reset
      return withBackground(null);
    } else if (modifier >= 40 && modifier <= 47) {
      return withBackground(AnsiColor.values[modifier - 40]);
    } else if (modifier >= 100 && modifier <= 107) {
      return withBackground(AnsiColor.values[modifier - 100 + 8]);
    }

    return this;
  }

  TextStyle toTextStyle() {
    return TextStyle(
      color: foreground?.color,
      backgroundColor: background?.color,
      fontWeight: bright ? FontWeight.bold : FontWeight.normal,
    );
  }

  @override
  bool operator ==(covariant AnsiStyle other) {
    return
      foreground == other.foreground &&
          background == other.background &&
          bright == other.bright;
  }

  @override
  int get hashCode => Object.hash(foreground, background, bright);
}
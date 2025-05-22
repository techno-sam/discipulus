/*
 *     Discipulus
 *     Copyright (C) 2023-2025  Sam Wagenaar
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
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

String csi = '\x1b[';

String codeToChars(int code) {
  return "$csi${code}m";
}

var _w = codeToChars;

class Fore {
  static String BLACK           = _w(30);
  static String RED             = _w(31);
  static String GREEN           = _w(32);
  static String YELLOW          = _w(33);
  static String BLUE            = _w(34);
  static String MAGENTA         = _w(35);
  static String CYAN            = _w(36);
  static String WHITE           = _w(37);
  static String RESET           = _w(39);

  // These are fairly well supported, but not part of the standard.
  static String LIGHTBLACK_EX   = _w(90);
  static String LIGHTRED_EX     = _w(91);
  static String LIGHTGREEN_EX   = _w(92);
  static String LIGHTYELLOW_EX  = _w(93);
  static String LIGHTBLUE_EX    = _w(94);
  static String LIGHTMAGENTA_EX = _w(95);
  static String LIGHTCYAN_EX    = _w(96);
  static String LIGHTWHITE_EX   = _w(97);
}


class Back {
  static String BLACK = _w(40);
  static String RED = _w(41);
  static String GREEN = _w(42);
  static String YELLOW = _w(43);
  static String BLUE = _w(44);
  static String MAGENTA = _w(45);
  static String CYAN = _w(46);
  static String WHITE = _w(47);
  static String RESET = _w(49);

// These are fairly well supported, but not part of the standard.
  static String LIGHTBLACK_EX = _w(100);
  static String LIGHTRED_EX = _w(101);
  static String LIGHTGREEN_EX = _w(102);
  static String LIGHTYELLOW_EX = _w(103);
  static String LIGHTBLUE_EX = _w(104);
  static String LIGHTMAGENTA_EX = _w(105);
  static String LIGHTCYAN_EX = _w(106);
  static String LIGHTWHITE_EX = _w(107);
}

class Style {
  static String BRIGHT = _w(1);
  static String DIM = _w(2);
  static String NORMAL = _w(22);
  static String RESET_ALL = _w(0);
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
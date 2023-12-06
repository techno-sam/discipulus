/*
 *     MSP430 emulator and assembler
 *     Copyright (C) 2023  Sam Wagenaar
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
 *
 */

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
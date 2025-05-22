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

import 'package:flutter/material.dart';

extension ColorManipulation on Color {
  Color darken([double factor = 0.1]) {
    assert(factor >= 0 && factor <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double factor = 0.1]) {
    assert(factor >= 0 && factor <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
        (hsl.lightness + factor).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  Color invert() {
    return Color.from(
      alpha: a,
      red: 1 - r,
      green: 1 - g,
      blue: 1 - b,
      colorSpace: colorSpace,
    );
  }
}
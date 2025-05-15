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

abstract interface class BiSelector<A, B> {
  Pair<Pair<int, A>, Pair<int, B>>? select(Iterable<Pair<Pair<int, A>, Pair<int, B>>> pairs);
}

class NearestIndexBiSelector<A, B> implements BiSelector<A, B> {
  final int _targetIndex;

  const NearestIndexBiSelector({required int targetIndex}): _targetIndex = targetIndex;

  int _score(Pair<Pair<int, A>, Pair<int, B>> pair) {
    return ((_targetIndex * 2) - (pair.first.first + pair.second.first)).abs();
  }

  @override
  Pair<Pair<int, A>, Pair<int, B>>? select(Iterable<Pair<Pair<int, A>, Pair<int, B>>> pairs) {
    return pairs.isEmpty ? null : pairs.minWith(_score);
  }
}

class FirstBiSelector<A, B> implements BiSelector<A, B> {
  const FirstBiSelector();

  @override
  Pair<Pair<int, A>, Pair<int, B>>? select(Iterable<Pair<Pair<int, A>, Pair<int, B>>> pairs) {
    return pairs.isEmpty ? null : pairs.first;
  }
}
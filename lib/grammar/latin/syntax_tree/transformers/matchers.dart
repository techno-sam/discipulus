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

abstract interface class BiMatcher<A, B> {
  Iterable<Pair<Pair<int, A>, Pair<int, B>>> find(List<SyntaxNode<dynamic>> nodes);
}

class OrderForwardBiMatcher<A, B> implements BiMatcher<A, B> {
  const OrderForwardBiMatcher();

  @override
  Iterable<Pair<Pair<int, A>, Pair<int, B>>> find(List<SyntaxNode<dynamic>> nodes) sync* {
    for (int i = 0; i < nodes.length - 1; i++) {
      final first = nodes[i];
      final second = nodes[i + 1];
      if (first is A && second is B) {
        yield Pair(Pair(i, first as A), Pair(i + 1, second as B));
      }
    }
  }
}

class OrderReversedBiMatcher<A, B> implements BiMatcher<A, B> {
  const OrderReversedBiMatcher();

  @override
  Iterable<Pair<Pair<int, A>, Pair<int, B>>> find(List<SyntaxNode<dynamic>> nodes) sync* {
    for (int i = 0; i < nodes.length - 1; i++) {
      final first = nodes[i];
      final second = nodes[i + 1];
      if (first is B && second is A) {
        yield Pair(Pair(i + 1, second as A), Pair(i, first as B));
      }
    }
  }
}

class OrderNeutralBiMatcher<A, B> implements BiMatcher<A, B> {
  const OrderNeutralBiMatcher();

  @override
  Iterable<Pair<Pair<int, A>, Pair<int, B>>> find(List<SyntaxNode<dynamic>> nodes) sync* {
    for (int i = 0; i < nodes.length - 1; i++) {
      final first = nodes[i];
      final second = nodes[i + 1];
      if (first is A && second is B) {
        yield Pair(Pair(i, first as A), Pair(i + 1, second as B));
      } else if (first is B && second is A) {
        yield Pair(Pair(i + 1, second as A), Pair(i, first as B));
      }
    }
  }
}

class ArbitraryPositionBiMatcher<A, B> implements BiMatcher<A, B> {
  const ArbitraryPositionBiMatcher();

  @override
  Iterable<Pair<Pair<int, A>, Pair<int, B>>> find(List<SyntaxNode<dynamic>> nodes) sync* {
    for (int i = 0; i < nodes.length; i++) {
      final first = nodes[i];
      if (first is! A) continue;
      for (int j = 0; j < nodes.length; j++) {
        if (i == j) continue;
        final second = nodes[j];
        if (second is! B) continue;
        yield Pair(Pair(i, first as A), Pair(j, second as B));
      }
    }
  }
}

class PredicateBiMatcher<A, B> implements BiMatcher<A, B> {
  final BiMatcher<A, B> _parent;
  final bool Function(A, B) _predicate;

  const PredicateBiMatcher({required BiMatcher<A, B> parent, required bool Function(A, B) predicate})
      : _parent = parent,
        _predicate = predicate;

  @override
  Iterable<Pair<Pair<int, A>, Pair<int, B>>> find(List<SyntaxNode<dynamic>> nodes) {
    return _parent.find(nodes).where((p) => _predicate(p.first.second, p.second.second));
  }
}
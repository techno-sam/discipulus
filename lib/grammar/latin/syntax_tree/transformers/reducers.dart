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

import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/nodes.dart';

abstract interface class BiReducer<A, B, C extends SyntaxNode<C>> {
  C reduce(A a, B b);
}

class AdjectiveNounReducer implements BiReducer<NP<dynamic>, AdjP<dynamic>, NP$m> {
  const AdjectiveNounReducer();

  @override
  NP$m reduce(NP<dynamic> a, AdjP<dynamic> b) {
    if (a is NP$m) {
      return a.cloneWithModifier(b);
    } else {
      return NP$m(a, [b]);
    }
  }
}

class SentenceReducer implements BiReducer<NP<dynamic>, VP, S> {
  const SentenceReducer();

  @override
  S reduce(NP<dynamic> a, VP b) => S(subject: a, predicate: b);
}
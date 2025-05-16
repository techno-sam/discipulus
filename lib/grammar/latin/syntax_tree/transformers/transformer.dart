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
import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/nodes.dart';
import 'matchers.dart';
import 'selectors.dart';
import 'reducers.dart';

export 'matchers.dart';
export 'selectors.dart';
export 'reducers.dart';

void _replace({
  required List<SyntaxNode<dynamic>> nodes,
  required Pair<int, SyntaxNode<dynamic>> primary,
  required SyntaxNode<dynamic> result,
  List<Pair<int, SyntaxNode<dynamic>>>? secondary
}) {
  nodes[primary.first] = result;

  if (secondary != null) {
    List<int> indices = secondary.map((p) => p.first).toSet().toList();
    indices.sort();
    for (int i = indices.length - 1; i >= 0; i--) {
      if (indices[i] == primary.first) continue;
      nodes.removeAt(indices[i]);
    }
  }
}

abstract class Transformer {
  const Transformer();

  String get label;

  bool transformOnce(List<SyntaxNode<dynamic>> nodes);
  void transformAll(List<SyntaxNode<dynamic>> nodes) {
    while (transformOnce(nodes)) {}
  }
}

class BiTransformer<A extends SyntaxNode<dynamic>, B extends SyntaxNode<dynamic>, C extends SyntaxNode<C>> extends Transformer {
  final String _label;
  final BiMatcher<A, B> _matcher;
  final BiSelector<A, B> _selector;
  final BiReducer<A, B, C> _reducer;

  const BiTransformer({
    required String label,
    required BiMatcher<A, B> matcher,
    required BiSelector<A, B> selector,
    required BiReducer<A, B, C> reducer
  }):
        _label = label,
        _matcher = matcher,
        _selector = selector,
        _reducer = reducer;

  @override
  String get label => _label;

  @override
  bool transformOnce(List<SyntaxNode<dynamic>> nodes) {
    final matched = _matcher.find(nodes);
    if (matched.isEmpty) {
      return false;
    }

    final selected = _selector.select(matched);
    if (selected == null) {
      return false;
    }

    final firstNode = selected.first.second;
    final secondNode = selected.second.second;

    final reduced = _reducer.reduce(firstNode, secondNode);

    _replace(
      nodes: nodes,
      primary: selected.first,
      result: reduced,
      secondary: [selected.second]
    );

    return true;
  }
}

class TriTransformer<A extends SyntaxNode<dynamic>, B extends SyntaxNode<dynamic>, C extends SyntaxNode<dynamic>, D extends SyntaxNode<D>> extends Transformer {
  final String _label;
  final TriMatcher<A, B, C> _matcher;
  final TriSelector<A, B, C> _selector;
  final TriReducer<A, B, C, D> _reducer;

  const TriTransformer({
    required String label,
    required TriMatcher<A, B, C> matcher,
    required TriSelector<A, B, C> selector,
    required TriReducer<A, B, C, D> reducer
  }):
        _label = label,
        _matcher = matcher,
        _selector = selector,
        _reducer = reducer;

  @override
  String get label => _label;

  @override
  bool transformOnce(List<SyntaxNode<dynamic>> nodes) {
    final matched = _matcher.find(nodes);
    if (matched.isEmpty) {
      return false;
    }

    final selected = _selector.select(matched);
    if (selected == null) {
      return false;
    }

    final firstNode = selected.first.second;
    final secondNode = selected.second.second;
    final thirdNode = selected.third.second;

    final reduced = _reducer.reduce(firstNode, secondNode, thirdNode);

    _replace(
      nodes: nodes,
      primary: selected.first,
      result: reduced,
      secondary: [
        selected.second,
        selected.third
      ]
    );

    return true;
  }
}

class VPTransformer extends Transformer {
  const VPTransformer();

  @override
  String get label => "VP Collector";

  @override
  bool transformOnce(List<SyntaxNode<dynamic>> nodes) {
    final verb = nodes.enumerate
        .whereSecondType<V>()
        .firstOrNull;
    if (verb == null) return false;

    final dirObj = verb.second.verbKind == VerbKind.intrans
        ? null
        : nodes.enumerate
        .whereSecondType<NP>()
        .where((p) => p.second.caze == Case.acc)
        .firstOrNull;

    final indObj = dirObj == null
        ? null
        : nodes.enumerate
        .whereSecondType<NP>()
        .where((p) => p.second.caze == Case.dat)
        .firstOrNull;

    final prepositionalPhrases = nodes.enumerate
        .whereSecondType<PP>()
        .toList();

    final vp = VP(
      verb: verb.second,
      directObject: dirObj?.second,
      indirectObject: indObj?.second,
      prepositionalPhrases: prepositionalPhrases.map((p) => p.second).toList()
    );

    _replace(nodes: nodes, primary: verb, result: vp, secondary: [
      if (dirObj != null) dirObj,
      if (indObj != null) indObj,
      ...prepositionalPhrases
    ]);

    return true;
  }
}
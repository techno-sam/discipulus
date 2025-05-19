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
import 'package:discipulus/grammar/latin/syntax_tree/clause_unit.dart';
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

  bool transformOnce(ClauseUnit clauseUnit);
  void transformAll(ClauseUnit clauseUnit) {
    while (transformOnce(clauseUnit)) {}
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
  bool transformOnce(ClauseUnit clauseUnit) {
    final List<SyntaxNode<dynamic>> nodes = clauseUnit.nodes;
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
  bool transformOnce(ClauseUnit clauseUnit) {
    final List<SyntaxNode<dynamic>> nodes = clauseUnit.nodes;
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

class VInfPTransformer extends Transformer {
  const VInfPTransformer();

  @override
  String get label => "VInfP Collector";

  @override
  bool transformOnce(ClauseUnit clauseUnit) {
    final List<SyntaxNode<dynamic>> nodes = clauseUnit.nodes;
    final verb = nodes.enumerate
        .whereSecondType<VInf>()
        .firstOrNull;
    if (verb == null) return false;

    final dirObj = nodes.enumerate
        .whereSecondType<NP>()
        .where((p) => p.second.caze == Case.acc)
        .firstOrNull;

    _replace(
      nodes: nodes,
      primary: verb,
      result: VInfP(
        inf: verb.second,
        directObject: dirObj?.second
      ),
      secondary: [
        if (dirObj != null) dirObj
      ]
    );

    return true;
  }
}

class VP$sTransformer extends Transformer {
  const VP$sTransformer();

  @override
  String get label => "VP_s Collector";

  @override
  bool transformOnce(ClauseUnit clauseUnit) {
    final List<SyntaxNode<dynamic>> nodes = clauseUnit.nodes;
    final verb = nodes.enumerate
        .whereSecondType<V>()
        .where((p) => !p.second.isLinkingVerb)
        .firstOrNull;
    if (verb == null) return false;

    final Pair<int, Either<NP<dynamic>, VInfP>>? dirObj = verb.second.verbKind == VerbKind.intrans
        ? null
        : (nodes.enumerate
                .whereSecondType<NP<dynamic>>()
                .where((p) => p.second.caze == Case.acc)
                .map((p) => Pair(p.first, Either<NP<dynamic>, VInfP>.a(p.second)))
                .toList()
              ..addAll(nodes.enumerate
                  .whereSecondType<VInfP>()
                  .map((p) => Pair(p.first, Either<NP<dynamic>, VInfP>.b(p.second)))))
            .minWithOrNull((v) => (v.first - verb.first).abs());

    final indObj = dirObj == null || dirObj.second.isB
        ? null
        : nodes.enumerate
        .whereSecondType<NP>()
        .where((p) => p.second.caze == Case.dat)
        .firstOrNull;

    final prepositionalPhrases = nodes.enumerate
        .whereSecondType<PP>()
        .toList();

    final sbar = nodes.enumerate
        .whereSecondType<ClauseUnit>()
        .map((p) {
          if (p.second.nodes.length != 1) return null;
          final node = p.second.nodes[0];
          if (node is! Sbar) return null;
          return Pair(p.first, node);
        })
        .where((p) => p != null)
        .firstOrNull;

    final vp = VP$s(
      verb: verb.second,
      directObject: dirObj?.second,
      indirectObject: indObj?.second,
      prepositionalPhrases: prepositionalPhrases.map((p) => p.second).toList(),
      sbar: sbar?.second
    );

    _replace(nodes: nodes, primary: verb, result: vp, secondary: [
      if (dirObj != null) Pair(
          dirObj.first,
          dirObj.second.apply<SyntaxNode<dynamic>>((a) => a, (b) => b)
      ),
      if (indObj != null) indObj,
      ...prepositionalPhrases,
      if (sbar != null) sbar,
    ]);

    return true;
  }
}

class VP$lTransformer extends Transformer {
  const VP$lTransformer();

  @override
  String get label => "VP_l Collector";

  @override
  bool transformOnce(ClauseUnit clauseUnit) {
    final List<SyntaxNode<dynamic>> nodes = clauseUnit.nodes;
    final verb = nodes.enumerate
        .whereSecondType<V>()
        .where((p) => p.second.isLinkingVerb)
        .firstOrNull;
    if (verb == null) return false;

    final dirObj = nodes.enumerate
        .whereSecondType<LP<dynamic>>()
        .where((p) => p.second.caze == Case.nom)
        .minWithOrNull((a) => -(a.first - 1).compareTo(verb.first));
    if (dirObj != null && !VP$l.isValidPair(verb.second, dirObj.second)) return false;

    final prepositionalPhrases = nodes.enumerate
        .whereSecondType<PP>()
        .toList();

    final sbar = nodes.enumerate
        .whereSecondType<ClauseUnit>()
        .map((p) {
      if (p.second.nodes.length != 1) return null;
      final node = p.second.nodes[0];
      if (node is! Sbar) return null;
      return Pair(p.first, node);
    })
        .where((p) => p != null)
        .firstOrNull;

    final vp = VP$l(
        verb: verb.second,
        directObject: dirObj?.second,
        prepositionalPhrases: prepositionalPhrases.map((p) => p.second).toList(),
        sbar: sbar?.second
    );

    _replace(nodes: nodes, primary: verb, result: vp, secondary: [
      if (dirObj != null) dirObj,
      ...prepositionalPhrases,
      if (sbar != null) sbar,
    ]);

    return true;
  }
}

class ClauseUnitSplitTransformer extends Transformer {
  const ClauseUnitSplitTransformer();

  @override
  String get label => "Clause Unit Splitter";

  @override
  bool transformOnce(final ClauseUnit clauseUnit) {
    final List<Pair<int, Conj<dynamic>>> conjunctions = clauseUnit.nodes.enumerate
        .whereSecondType<Conj>()
        .toList();

    if (conjunctions.isEmpty) {
      return false;
    }

    // [start, end)
    final List<Pair<int, int>> ranges = [Pair(0, conjunctions[0].first)];

    for (int i = 0; i < conjunctions.length - 1; i++) {
      ranges.add(Pair(conjunctions[i].first, conjunctions[i + 1].first));
    }

    ranges.add(Pair(conjunctions.last.first, clauseUnit.nodes.length));

    final List<SyntaxNode<dynamic>> nodes = clauseUnit.nodes;
    clauseUnit.nodes = nodes.sublist(ranges[0].first, ranges[0].second);

    ClauseUnit parent = clauseUnit;
    for (int i = 1; i < ranges.length; i++) {
      final ClauseUnit newClauseUnit = ClauseUnit(
        nodes.sublist(ranges[i].first, ranges[i].second),
        parent: parent
      );

      parent.nodes.add(newClauseUnit);
      parent = newClauseUnit;
    }

    return true;
  }
}

class RelClauseSplitTransformer extends Transformer {
  const RelClauseSplitTransformer();

  @override
  String get label => "Relative Clause Unit Splitter";

  @override
  bool transformOnce(final ClauseUnit clauseUnit) {
    final List<Pair<int, Rel>> relativePronouns = clauseUnit.nodes.enumerate
        .whereSecondType<Rel>()
        .toList();

    if (relativePronouns.isEmpty) {
      return false;
    }

    // [start, end)
    final List<Pair<int, int>> splitRanges = [];

    for (final pair in relativePronouns) {
      for (int i = pair.first + 1; i < clauseUnit.nodes.length; i++) {
        final node = clauseUnit.nodes[i];
        if (node is V) {
          splitRanges.add(Pair(pair.first, i+1));
          break;
        }
      }
    }

    // Sort last-to-first so we can safely remove without exploding things
    splitRanges.sort((a, b) => -a.first.compareTo(b.first));

    for (final splitRange in splitRanges) {
      final ClauseUnit child = ClauseUnit(
        clauseUnit.nodes.sublist(splitRange.first, splitRange.second),
        parent: clauseUnit
      );
      clauseUnit.nodes[splitRange.first] = child;

      for (int i = splitRange.second - 1; i > splitRange.first; i--) {
        clauseUnit.nodes.removeAt(i);
      }
    }

    return true;
  }
}

class RelClauseUnpackTransformer extends Transformer {
  const RelClauseUnpackTransformer();

  @override
  String get label => "Relative Clause Unpacker";

  @override
  bool transformOnce(ClauseUnit clauseUnit) {
    final relClause = clauseUnit.nodes.enumerate
        .whereSecondType<ClauseUnit>()
        .map((p) {
          if (p.second.nodes.length != 1) return null;
          final node = p.second.nodes[0];
          if (node is! RelClause) return null;
          return Pair(p.first, node);
        })
        .where((p) => p != null)
        .firstOrNull;

    if (relClause != null) {
      clauseUnit.nodes[relClause.first] = relClause.second;
      return true;
    } else {
      return false;
    }
  }
}

/// De-mangle linking verbs. The architecture isn't otherwise smart enough to require a subject.
class LinkingSentenceDemanglingTransformer extends Transformer {
  const LinkingSentenceDemanglingTransformer();

  @override
  String get label => "Linking Sentence Demangler";

  @override
  bool transformOnce(ClauseUnit clauseUnit) {
    if (clauseUnit.parent != null) return false;

    final sentence = clauseUnit.nodes.enumerate
        .whereSecondType<S>()
        .firstOrNull;
    if (sentence == null) return false;

    final subject = sentence.second.subject;
    final predicate = sentence.second.predicate;

    if (subject is! NP$implicitSubject) return false;
    if (predicate is! VP$l) return false;
    if (predicate.directObject is! NP<dynamic>) return false;
    if (!predicate.hasPrepositionalPhrases) return false;

    clauseUnit.nodes[sentence.first] = S(
      subject: predicate.directObject as NP<dynamic>,
      predicate: predicate.withoutDirectObject()
    );

    return true;
  }
}

class SequentialTransformer extends Transformer {
  final String _label;
  final List<Transformer> _children;
  final void Function(String, ClauseUnit)? _onTransform;

  const SequentialTransformer({
    required String label,
    required List<Transformer> children,
    void Function(String, ClauseUnit)? onTransform
  }): _label = label, _children = children, _onTransform = onTransform;

  @override
  String get label => _label;

  @override
  bool transformOnce(ClauseUnit clauseUnit) {
    bool any = false;
    for (final transformer in _children) {
      if (transformer.transformOnce(clauseUnit)) {
        any = true;
      }
      if (_onTransform != null) {
        _onTransform(transformer.label, clauseUnit);
      }
    }
    return any;
  }

  @override
  void transformAll(ClauseUnit clauseUnit) {
    if (_onTransform != null) {
      print("\tStarting group transform for clause unit of length ${clauseUnit.nodes.length}\n");
    }
    for (final transformer in _children) {
      if (transformer.transformOnce(clauseUnit) && _onTransform != null) {
        _onTransform(transformer.label, clauseUnit);
      }
    }
  }
}
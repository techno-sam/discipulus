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
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'node/nodes.dart';
import 'transformers/transformer.dart';

void _dbg(List<SyntaxNode> nodes, [String indent = ""]) {
  print("${nodes.length.labeled("node")}:");
  for (final node in nodes) {
    print(indent+TreeDebugNode.getDebugLines(node).join("\n$indent"));
  }
}

void parse(Sentence sentence) {
  List<SyntaxNode> nodes = sentence.words.map(toSyntaxNode).toList();
  _dbg(nodes, "\t");

  print("\nTransforming...\n");

  final transformers = [
    const BiTransformer<NP<dynamic>, AdjP<dynamic>, NP$m>(
      label: "Adjective Applicator",
      matcher: PredicateBiMatcher(
        parent: OrderNeutralBiMatcher(),
        predicate: NP$m.isValidPair,
      ),
      selector: NearestIndexBiSelector(targetIndex: 0),
      reducer: AdjectiveNounReducer(),
    ),
    const BiTransformer<P, NP<dynamic>, PP>(
      label: "Preposition Applicator",
      matcher: PredicateBiMatcher(
        parent: OrderForwardBiMatcher(),
        predicate: PP.isValidPair,
      ),
      selector: NearestIndexBiSelector(targetIndex: 0),
      reducer: PrepositionReducer(),
    ),
    const TriTransformer<NP<dynamic>, Et, NP<dynamic>, NP$c>(
      label: "Conjunction Applicator",
      matcher: PredicateTriMatcher(
        parent: OrderForwardTriMatcher(),
        predicate: NP$c.isValidTriple,
      ),
      selector: NearestIndexTriSelector(targetIndex: 0),
      reducer: EtReducer()
    ),
    const BiTransformer<V<dynamic>, AdvP<dynamic>, V$m>(
      label: "Adverb Applicator", // todo ArbitraryPosition matcher after clause separation
      matcher: OrderNeutralBiMatcher(),
      selector: NearestIndexBiSelector(targetIndex: 0),
      reducer: AdverbReducer(),
    ),
    const VPTransformer(),
    const BiTransformer<NP<dynamic>, VP, S>(
      label: "Sentence Applicator",
      matcher: FallbackABiMatcher(
        primary: PredicateBiMatcher(
          parent: ArbitraryPositionBiMatcher(),
          predicate: S.isValidPair,
        ),
        fallback: NP$implicitSubject.fromVerb
      ),
      selector: FirstBiSelector(),
      reducer: SentenceReducer(),
    ),
  ];

  for (final transformer in transformers) {
    transformer.transformAll(nodes);
    print("\n${transformer.label}:");
    _dbg(nodes, "\t");
  }
}
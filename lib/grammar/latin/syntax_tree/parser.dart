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
import 'package:discipulus/grammar/latin/syntax_tree/clause_unit.dart';
import 'node/nodes.dart';
import 'transformers/transformer.dart';

void _dbg(ClauseUnit clauseUnit, [String indent = "", String indent0 = ""]) {
  final nodes = clauseUnit.nodes;
  print("$indent0${nodes.length.labeled("node")}:");
  for (final node in nodes) {
    print(indent+TreeDebugNode.getDebugLines(node).join("\n$indent"));
  }
}

ClauseUnit parse(Sentence sentence, {bool showIntermediate = true}) {
  ClauseUnit clauseUnit = ClauseUnit(sentence.words.map(toSyntaxNode).toList());

  if (showIntermediate) {
    _dbg(clauseUnit, "\t");
    print("\nTransforming...\n");
  }

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
      label: "Adverb Applicator (Adjacent)",
      matcher: OrderNeutralBiMatcher(),
      selector: NearestIndexBiSelector(targetIndex: 0),
      reducer: AdverbReducer(),
    ),
    const ClauseUnitSplitTransformer(),
    const RelClauseSplitTransformer(),
    const BiTransformer<V<dynamic>, AdvP<dynamic>, V$m>(
      label: "Adverb Applicator (Arbitrary Positions)",
      matcher: ArbitraryPositionBiMatcher(),
      selector: NearestIndexBiSelector(targetIndex: 0),
      reducer: AdverbReducer(),
    ),
    SequentialTransformer(
        label: "Clause Builder",
        onTransform: showIntermediate ? (label, clauseUnit) {
          print("\t$label:");
          _dbg(clauseUnit, "\t\t", "\t");
          print("");
        } : null,
        children: const [
          RelClauseUnpackTransformer(),
          BiTransformer<NP<dynamic>, RelClause, NP$r>(
            label: "Relative Clause Applicator",
            matcher: PredicateBiMatcher(
              parent: OrderForwardBiMatcher(),
              predicate: NP$r.isValidPair,
            ),
            selector: NearestIndexBiSelector(targetIndex: 0),
            reducer: NounRelClauseReducer(),
          ),
          VPTransformer(),
          BiTransformer<NP<dynamic>, VP, S>(
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
          BiTransformer<Conj<dynamic>, S, Sbar>(
            label: "Conjunction Applicator",
            matcher: OrderForwardBiMatcher(),
            selector: NearestIndexBiSelector(targetIndex: 0),
            reducer: SbarReducer(),
          ),
          BiTransformer<Rel, S, RelClause>(
            label: "Relative Pronoun Applicator",
            matcher: PredicateBiMatcher(
              parent: OrderForwardBiMatcher(),
              predicate: RelClause.isValidPair,
            ),
            selector: NearestIndexBiSelector(targetIndex: 0),
            reducer: RelClauseReducer(),
          ),
        ]
    ),
  ];

  for (final transformer in transformers) {
    if (showIntermediate) {
      print("\n${transformer.label}:");
    }
    clauseUnit.applyToSelfAndChildren(transformer.transformAll);
    if (showIntermediate) {
      _dbg(clauseUnit, "\t");
    }
  }

  return clauseUnit;
}
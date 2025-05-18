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
import 'package:discipulus/grammar/latin/syntax_tree/node/nodes.dart';
import 'package:discipulus/grammar/latin/syntax_tree/parser.dart' as parser;

void main() {
  // "Cornelia quae cotidie ambulat edit glirem quod famem habet"
  // "Cornelia quae cotidie ambulat edit glirem quod famem habet et Romana est"
  // "Sextus qui cotidie celerrime ambulat dat glirem puellae Romanae"
  const raw = "Sextus et Flavia glires non edunt quod non sunt cives Romani";
  final bundle = SentenceBundle.fromSentence(raw, debugMode: true);

  print("\n\nTranslating: $raw");

  for (final pair in bundle.allPossibleSentences().enumerate) {
    final sentence = pair.second;
    final clauseUnit = parser.parse(sentence, showIntermediate: false);
    final nodes = clauseUnit.nodes;

    if (nodes.length == 1 && nodes[0] is S) {
      print("\nSentence idx ${pair.first}:");
      print(TreeDebugNode.getDebugLines(nodes[0]).join("\n"));
    }
    /*print("\nSentence idx ${pair.first}:");
    print(TreeDebugNode.getDebugLines(clauseUnit).join("\n"));*/
  }
}
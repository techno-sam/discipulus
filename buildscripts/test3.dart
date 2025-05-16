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

import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/nodes.dart';
import 'package:discipulus/grammar/latin/syntax_tree/parser.dart' as parser;

void main() {
  const raw = "Cornelia et pueri Romani timidi magnos glires celeriter edunt in foro";
  final bundle = SentenceBundle.fromSentence(raw, debugMode: true);

  print("\n\nTranslating: $raw");

  for (final sentence in bundle.allPossibleSentences()) {
    final nodes = parser.parse(sentence, showIntermediate: false);

    if (nodes.length == 1 && nodes[0] is S) {
      print("\n${TreeDebugNode.getDebugLines(nodes[0]).join("\n")}");
    }
  }
}
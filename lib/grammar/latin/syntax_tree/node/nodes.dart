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
import 'package:discipulus/grammar/latin/conjunction.dart';
import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/word_types.dart';
import 'np.dart';
import 'vp.dart';
import 'singletons.dart';

export 'np.dart';
export 'vp.dart';
export 's.dart';
export 'singletons.dart';

SyntaxNode toSyntaxNode(Word word) {
  if (word is Verb && word.mood == Mood.ind) {
    return V(word);
  } else if (word is Noun) {
    return NP$s(word);
  } else if (word is Adjective) {
    return AdjP$s(word);
  } else if (word is Conjunction && word.isEt) {
    return const Et();
  } else {
    throw ArgumentError.value(
        word, "word",
        "Could not find a matching syntax node"
    );
  }
}
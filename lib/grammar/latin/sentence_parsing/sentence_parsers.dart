/*
 *     Discipulus
 *     Copyright (C) 2023  Sam Wagenaar
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

import 'package:discipulus/grammar/english/micro_translation.dart' as english;
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/verb.dart';

import 'utils.dart';

typedef SentenceParser = String? Function(Sentence);

String? standaloneVerb(Sentence sentence) {
  if (sentence.words.length == 1) {
    final word = sentence.words[0];
    if (word is Verb && word.mood == Mood.ind) {
      return english.translateVerb(word);
    }
  }
  return null;
}

String? verbWithNominative(Sentence sentence) {
  final verb = getVerb(sentence);
  if (verb == null) return null;
  final noun = getNearestNoun(sentence, verb.second.person, verb.first);
  if (noun == null) return null;
  return english.translateVerb(verb.second, noun.second);
}

String? superParse(Sentence sentence) {
  for (final parser in [standaloneVerb, verbWithNominative]) {
    final result = parser.call(sentence);
    if (result != null) return result;
  }
  return null;
}
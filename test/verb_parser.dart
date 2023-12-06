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

import 'package:discipulus/ffi/words_low_level.dart';
import 'package:discipulus/grammar/latin/verb.dart';
import 'package:flutter_test/flutter_test.dart';

final WordsLL words = WordsLL(debugMode: true);

void testVerb(String verb, Tense tense, Mood group, int person, bool plural) {
  test('Verb Parsing $verb', () async {
    if (group != Mood.inf) {
      expect(person >= 1 && person <= 3, true, reason: "Valid person");
    }
    String wordsOut = words.wordsDefault(verb);
    Verb parsed = Verb.fromWordsLines(wordsOut);

    print(parsed);
    expect(parsed.tense, tense, reason: "Correct tense");
    expect(parsed.mood, group, reason: "Correct group");
    if (group != Mood.inf) {
      expect(parsed.person.person, person, reason: "Correct person");
      expect(parsed.person.plural, plural, reason: "Correct person count");
    }
  });
}

void main() {
  testVerb('audio', Tense.pres, Mood.ind, 1, false);
  testVerb('regere', Tense.pres, Mood.inf, 0, false);
  testVerb('audit', Tense.pres, Mood.ind, 3, false);
  testVerb('sedent', Tense.pres, Mood.ind, 3, true);
}
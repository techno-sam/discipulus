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

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/verb.dart';

Pair<int, Verb>? getVerb(Sentence sentence) {
  return sentence.words.enumerate.whereSecondType<Verb>().firstOrNull;
}

Pair<int, Noun>? getNearestNoun(Sentence sentence, Person verbPerson, int verbIndex) {
  if (verbPerson.person != 3) return null;
  // Bob walks; Bob and Joe walk
  final nouns = sentence.words.enumerate
      .whereSecondType<Noun>()
      .where((p) => p.second.plural == verbPerson.plural && p.second.caze == Case.nom);
  if (nouns.isEmpty) return null;
  return nouns.minWith((p) => (verbIndex - p.first).abs());
}
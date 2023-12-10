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

Pair<Pair<int, A>, Pair<int, B>>? _getNearestPair<A, B>(Sentence sentence,
    bool Function(A, B) predicate, int targetIndex) {
  final Iterable<Pair<Pair<int, A>, Pair<int, B>>> options = sentence.enumeratedUnusedWords.toList().pairs
      .whereFirst$SecondType<A>()
      .whereSecond$SecondType<B>()
      .where((e) => predicate(e.first.second, e.second.second));
  if (options.isEmpty) return null;
  return options.minWith((p) => ((targetIndex*2) - (p.first.first + p.second.first)).abs());
}

Pair<int, Verb>? getVerb(Sentence sentence) {
  return sentence.enumeratedUnusedWords.whereSecondType<Verb>().firstOrNull;
}

Pair<int, Noun>? getNearestSubjectNoun(Sentence sentence, Person verbPerson, int verbIndex) {
  if (verbPerson.person != 3) return null;
  // Bob walks; Bob and Joe walk
  final nouns = sentence.enumeratedUnusedWords
      .whereSecondType<Noun>()
      .where((p) => p.second.plural == verbPerson.plural && p.second.caze == Case.nom);
  if (nouns.isEmpty) return null;
  return nouns.minWith((p) => (verbIndex - p.first).abs());
}

Pair<int, Noun>? getNearestGeneralNoun(Sentence sentence, int originIndex,
    {required Case caze, Person? targetPerson}) {
  // Bob walks; Bob and Joe walk
  final nouns = sentence.enumeratedUnusedWords
      .whereSecondType<Noun>()
      .where((p) => (targetPerson == null || p.second.plural == targetPerson.plural) && p.second.caze == caze);
  if (nouns.isEmpty) return null;
  return nouns.minWith((p) => (originIndex - p.first).abs());
}
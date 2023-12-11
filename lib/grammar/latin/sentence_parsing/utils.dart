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
import 'package:discipulus/grammar/latin/adjective.dart';
import 'package:discipulus/grammar/latin/conjunction.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/verb.dart';

Triple<Pair<int, A>, Pair<int, B>, Pair<int, C>>? _getNearestTriple<A, B, C>(Sentence sentence, bool Function(A, B, C) predicate, int targetIndex) {
  final Iterable<Triple<Pair<int, A>, Pair<int, B>, Pair<int, C>>> options = sentence.enumeratedUnusedWords.triples
      .whereFirst$SecondType<A>()
      .whereSecond$SecondType<B>()
      .whereThird$SecondType<C>()
      .where((e) => predicate(e.first.second, e.second.second, e.third.second));
  if (options.isEmpty) return null;
  return options.minWith((p) => ((targetIndex*3) - (p.first.first + p.second.first + p.third.first)).abs());
}

Pair<Pair<int, A>, Pair<int, B>>? _getNearestPair<A, B>(Sentence sentence,
    bool Function(A, B) predicate, int targetIndex) {
  final Iterable<Pair<Pair<int, A>, Pair<int, B>>> options = sentence.enumeratedUnusedWords.toList().pairs
      .whereFirst$SecondType<A>()
      .whereSecond$SecondType<B>()
      .where((e) => predicate(e.first.second, e.second.second));
  if (options.isEmpty) return null;
  return options.minWith((p) => ((targetIndex*2) - (p.first.first + p.second.first)).abs());
}

void applyAdjectives(Sentence original) {
  if (original is AccountingSentence) {
    throw "Cannot apply adjectives to an accounting sentence";
  }
  // handle adjective-noun pairs
  var nearestPair = _getNearestPair<Adjective, Noun>(original, (a, b) => b.canModify(a), 0);
  while (nearestPair != null) {
    final adjective = nearestPair.first.second;
    final noun = nearestPair.second.second;
    final modified = noun.modify(adjective)!;
    original.words[nearestPair.first.first] = modified;
    original.words.removeAt(nearestPair.second.first);
    nearestPair = _getNearestPair<Adjective, Noun>(original, (a, b) => b.canModify(a), 0);
  }
  // handle noun-adjective pairs
  var nearestPair2 = _getNearestPair<Noun, Adjective>(original, (a, b) => a.canModify(b), 0);
  while (nearestPair2 != null) {
    final adjective = nearestPair2.second.second;
    final noun = nearestPair2.first.second;
    final modified = noun.modify(adjective)!;
    original.words[nearestPair2.first.first] = modified;
    original.words.removeAt(nearestPair2.second.first);
    nearestPair2 = _getNearestPair<Noun, Adjective>(original, (a, b) => a.canModify(b), 0);
  }
}

void applyConjunctions(Sentence s) {
if (s is AccountingSentence) {
    throw "Cannot apply conjunctions to an accounting sentence";
  }
  // handle conjunctions
  var nearestTriple = _getNearestTriple<Noun, Conjunction, Noun>(s, (a, b, c) => b.canMerge(a, c), 0);
  while (nearestTriple != null) {
    final conjunction = nearestTriple.second.second;
    final nounA = nearestTriple.first.second;
    final nounB = nearestTriple.third.second;
    final merged = conjunction.merge(nounA, nounB)!;
    s.words[nearestTriple.first.first] = merged;
    s.words.removeAt(nearestTriple.third.first);
    s.words.removeAt(nearestTriple.second.first);
    nearestTriple = _getNearestTriple<Noun, Conjunction, Noun>(s, (a, b, c) => b.canMerge(a, c), 0);
  }
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
  return nouns.minWith((p) => (verbIndex - p.first).weightedAbs());
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
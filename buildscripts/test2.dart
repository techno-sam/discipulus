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

// ignore_for_file: avoid_print

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/latin/adjective.dart';
import 'package:discipulus/grammar/latin/conjunction.dart';
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/preposition.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart' as debug;
import 'package:discipulus/grammar/latin/syntax_tree/parser.dart' as parser;
import 'package:discipulus/grammar/latin/verb.dart';
import 'package:discipulus/utils/colors.dart';

void translateSentenceOld(String sentence) {
  print("\n\nAll possibilities for ${Style.BRIGHT}$sentence${Style.RESET_ALL}${Fore.LIGHTBLACK_EX}${Style.DIM}");
  final SentenceBundle bundle;
  try {
    bundle = SentenceBundle.fromSentence(sentence, debugMode: true, print: print);
  } catch (e, s) {
    print(Style.RESET_ALL+Fore.RED);
    print(e);
    print(s);
    return;
  }
  bundle.printAllPossibilities(skipUntranslatable: true);
}

Sentence puellaRomanaGliresEdit() {
  return Sentence(
    original: "Puella Romana glires edit",
    words: [
      Noun.allTheParts(caze: Case.nom, plural: false, gender: Gender.f, parts: const Couple("puella", "puellae"), translations: [["girl"]]),
      Adjective.allTheParts(caze: Case.nom, plural: false, gender: Gender.f, parts: ["romanus", "romana"], translations: [["Roman"]], comparisonType: ComparisonType.pos),
      Noun.allTheParts(caze: Case.acc, plural: true, gender: Gender.m, parts: const Couple("glis", "gliris"), translations: [["dormouse"]]),
      Verb(tense: Tense.pres, person: Person(person: 3, plural: false), mood: Mood.ind, principleParts: "edo, edere", translations: "eat", verbKind: VerbKind.trans),
    ],
  );
}

Sentence corneliaEtPueriRomaniTimidiGliresEdunt() {
  return Sentence(
    original: "Cornelia et pueri Romani timidi glires edunt",
    words: [
      Noun.allTheParts(caze: Case.nom, plural: false, gender: Gender.f, parts: const Couple("Cornelia", "Corneliae"), translations: [["Cornelia"]], isProper: true),
      Conjunction(word: "et", translations: [["and"]]),
      Noun.allTheParts(caze: Case.nom, plural: true, gender: Gender.m, parts: const Couple("puer", "pueri"), translations: [["boy"]]),
      Adjective.allTheParts(caze: Case.nom, plural: true, gender: Gender.m, parts: ["romanus", "romana"], translations: [["Roman"]], comparisonType: ComparisonType.pos),
      Adjective.allTheParts(caze: Case.nom, plural: true, gender: Gender.m, parts: ["timidus", "timida", "-um"], translations: [["timid"]], comparisonType: ComparisonType.pos),
      Noun.allTheParts(caze: Case.acc, plural: true, gender: Gender.m, parts: const Couple("glis", "gliris"), translations: [["dormouse"]]),
      Verb(tense: Tense.pres, person: Person(person: 3, plural: true), mood: Mood.ind, principleParts: "edo, edere", translations: "eat", verbKind: VerbKind.trans),
    ],
  );
}

Sentence corneliaEtPueriRomaniTimidiGliresEduntInForo() {
  return Sentence(
    original: "Cornelia et pueri Romani timidi glires edunt in foro",
    words: [
      Noun.allTheParts(caze: Case.nom, plural: false, gender: Gender.f, parts: const Couple("Cornelia", "Corneliae"), translations: [["Cornelia"]], isProper: true),
      Conjunction(word: "et", translations: [["and"]]),
      Noun.allTheParts(caze: Case.nom, plural: true, gender: Gender.m, parts: const Couple("puer", "pueri"), translations: [["boy"]]),
      Adjective.allTheParts(caze: Case.nom, plural: true, gender: Gender.m, parts: ["romanus", "romana"], translations: [["Roman"]], comparisonType: ComparisonType.pos),
      Adjective.allTheParts(caze: Case.nom, plural: true, gender: Gender.m, parts: ["timidus", "timida", "-um"], translations: [["timid"]], comparisonType: ComparisonType.pos),
      Noun.allTheParts(caze: Case.acc, plural: true, gender: Gender.m, parts: const Couple("glis", "gliris"), translations: [["dormouse"]]),
      Verb(tense: Tense.pres, person: Person(person: 3, plural: true), mood: Mood.ind, principleParts: "edo, edere", translations: "eat", verbKind: VerbKind.trans),
      Preposition(word: "in", caze: Case.abl, translations: [["in"]]),
      Noun.allTheParts(caze: Case.abl, plural: false, gender: Gender.n, parts: const Couple("forum", "fori"), translations: [["market"]]),
    ],
  );
}

void main() {
  //debug.testMe();

  final sentence = corneliaEtPueriRomaniTimidiGliresEdunt();
  //translateSentenceOld(sentence.original);
  parser.parse(sentence);
}
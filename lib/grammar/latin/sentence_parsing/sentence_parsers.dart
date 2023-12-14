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
import 'package:discipulus/grammar/english/micro_translation.dart' as english;
import 'package:discipulus/grammar/latin/conjunction.dart';
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/preposition.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/verb.dart';
import 'package:discipulus/utils/colors.dart';

import 'utils.dart';

typedef SentenceParser = String? Function(Sentence);

String? standaloneVerb(Sentence sentence, {void Function(String message) print = _printBackup}) {
  if (sentence.words.length == 1) {
    final word = sentence.words[0];
    if (word is Verb && word.mood == Mood.ind) {
      return english.translateVerb(word);
    }
  }
  return null;
}

String? verbWithNominative(Sentence sentence, {void Function(String message) print = _printBackup}) {
  final verb = getVerb(sentence, Mood.ind);
  if (verb == null) return null;
  final noun = getNearestSubjectNoun(sentence, verb.second.person, verb.first);
  if (noun == null) return null;
  return english.translateVerb(verb.second, noun.second);
}

enum SentencePiece {
  leadingConjunction(-1),
  subject_verb(0), // ignore: constant_identifier_names
  object(1),
  indirectObject(2),
  infinitiveVerb(3),
  ;
  final int ordering;

  const SentencePiece(this.ordering);
}

Noun? getNearestSuperSubject(List<Noun> superSubjectStack, Person verbPerson) {
  if (verbPerson.person != 3) return null;
  for (final noun in superSubjectStack.reversed) {
    if (noun.plural == verbPerson.plural && noun.caze == Case.nom) {
      return noun;
    }
  }
  return null;

}

/*
Sentence order:

[verb-subject pair]
[{accusative noun | preposition-accusative pair}]
[by/from/with {ablative noun | preposition-ablative pair}]
 */
// should modify superSubjectStack to add own subject for future sentences
String? accountingBased(Sentence sentence, List<Noun> superSubjectStack, bool isPrimaryClause, {void Function(String message) print = _printBackup}) {
  final AccountingSentence accounting = sentence.makeAccounting();

  final verb = getVerb(accounting, Mood.ind);
  if (verb == null) return null;
  accounting.accountFor(verb.first);

  Noun? subjectNoun = getNearestSuperSubject(superSubjectStack, verb.second.person);
  final bool subjectNounFromSuper = subjectNoun != null;
  if (subjectNoun == null) {
    final subjectNounDat = getNearestSubjectNoun(accounting, verb.second.person, verb.first);
    subjectNoun = subjectNounDat?.second;
    if (subjectNounDat != null) {
      accounting.accountFor(subjectNounDat.first);
    }
  }
  if (subjectNoun != null) {
    superSubjectStack.add(subjectNoun);
  }

  final List<(SentencePiece, String, int)> pieces = [];
  pieces.add((SentencePiece.subject_verb, english.translateVerb(verb.second, subjectNoun, subjectNounFromSuper), verb.first));

  if (!isPrimaryClause && sentence.words[0] is Conjunction) {
    Conjunction conjunction = sentence.words[0] as Conjunction;
    accounting.accountFor(0);
    pieces.add((SentencePiece.leadingConjunction, conjunction.primaryTranslation, 0));
  }

  Pair<int, Noun>? objectNoun = verb.second.verbKind == VerbKind.intrans
      ? null
      : getNearestGeneralNoun(accounting, verb.first, caze: verb.second.isToBe ? Case.nom : Case.acc);
  if (objectNoun == null && verb.second.isToBe && verb.second.verbKind != VerbKind.intrans) {
    objectNoun = getNearestGeneralNoun(accounting, verb.first, caze: Case.acc);
  }
  if (objectNoun != null) {
    accounting.accountFor(objectNoun.first);
    pieces.add((SentencePiece.object, objectNoun.second.verbProperConsideringPrimaryTranslation(verb.second), objectNoun.first));
  }

  Pair<int, Noun>? accusativeNoun = getNearestGeneralNoun(accounting, verb.first,
      caze: Case.acc, predicate: (noun) => noun is PrepositionedNoun);
  while (accusativeNoun != null) {
    accounting.accountFor(accusativeNoun.first);
    String translation;
    if (accusativeNoun.second is PrepositionedNoun) {
      translation = accusativeNoun.second.properConsideringPrimaryTranslation;
    } else {
      throw "Expected prepositioned noun";
    }
    pieces.add((SentencePiece.indirectObject, translation, accusativeNoun.first));
    accusativeNoun = getNearestGeneralNoun(accounting, accusativeNoun.first, caze: Case.acc);
  }

  Pair<int, Noun>? ablativeNoun = getNearestGeneralNoun(accounting, verb.first, caze: Case.abl);
  while (ablativeNoun != null) {
    accounting.accountFor(ablativeNoun.first);
    String translation;
    if (ablativeNoun.second is PrepositionedNoun) {
      translation = ablativeNoun.second.properConsideringPrimaryTranslation;
    } else {
      translation = "by/from/with ${ablativeNoun.second.properConsideringPrimaryTranslation}";
    }
    pieces.add((SentencePiece.indirectObject, translation, ablativeNoun.first));
    ablativeNoun = getNearestGeneralNoun(accounting, ablativeNoun.first, caze: Case.abl);
  }

  Pair<int, Noun>? dativeNoun = getNearestGeneralNoun(accounting, verb.first, caze: Case.dat);
  while (dativeNoun != null) {
    accounting.accountFor(dativeNoun.first);
    String translation;
    if (dativeNoun.second is PrepositionedNoun) {
      translation = dativeNoun.second.properConsideringPrimaryTranslation;
    } else {
      translation = "to/for ${dativeNoun.second.properConsideringPrimaryTranslation}";
    }
    pieces.add((SentencePiece.indirectObject, translation, dativeNoun.first));
    dativeNoun = getNearestGeneralNoun(accounting, dativeNoun.first, caze: Case.abl);
  }

  final Pair<int, Verb>? infinitiveVerb = getVerb(accounting, Mood.inf);
  if (infinitiveVerb != null) {
    accounting.accountFor(infinitiveVerb.first);
    pieces.add((SentencePiece.infinitiveVerb, infinitiveVerb.second.primaryTranslation, infinitiveVerb.first));
  }

  pieces.stableSort(((a, b) {
    int primary = a.$1.ordering.compareTo(b.$1.ordering);
    if (primary == 0) {            // within same-priority pieces
      return a.$3.compareTo(b.$3); // compare by sentence order in the original latin
    }
    return primary;
  }));
  final translatedSentence = pieces.map((e) => e.$2).join(" ").replaceAll("  ", " "); // deduplicate spaces

  if (accounting.isNotFullyAccountedFor) {
    print("${Fore.LIGHTBLACK_EX}${Style.DIM}>> accounting: ${accounting.accountingSummary}${Fore.LIGHTBLACK_EX} would be: `$translatedSentence`${Style.RESET_ALL}");
    return null;
  }
  return translatedSentence;
}

const _printBackup = print;

String? superParse(Sentence sentence, List<Noun> superSubjectStack, bool isPrimaryClause, {void Function(String message) print = _printBackup}) {
  for (final parser in [accountingBased/*, standaloneVerb, verbWithNominative*/]) {
    print("${Fore.LIGHTBLACK_EX}${Style.DIM}> trying parser: ${parser.name}${Style.RESET_ALL}");
    final result = parser.call(sentence, superSubjectStack, isPrimaryClause, print: print);
    if (result != null) return result;
  }
  return null;
}
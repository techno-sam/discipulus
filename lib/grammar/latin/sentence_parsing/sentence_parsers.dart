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
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/verb.dart';
import 'package:discipulus/utils/colors.dart';

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
  final noun = getNearestSubjectNoun(sentence, verb.second.person, verb.first);
  if (noun == null) return null;
  return english.translateVerb(verb.second, noun.second);
}

enum SentencePiece {
  subject_verb(0), // ignore: constant_identifier_names
  object(1),
  indirectObject(2),
  ;
  final int ordering;

  const SentencePiece(this.ordering);
}

/*
Sentence order:

[verb-subject pair]
[{accusative noun | preposition-accusative pair}]
[by/from/with {ablative noun | preposition-ablative pair}]
 */
String? accountingBased(Sentence sentence) {
  final AccountingSentence accounting = sentence.makeAccounting();

  final verb = getVerb(accounting);
  if (verb == null) return null;
  accounting.accountFor(verb.first);

  final subjectNoun = getNearestSubjectNoun(accounting, verb.second.person, verb.first);
  if (subjectNoun != null) {
    accounting.accountFor(subjectNoun.first);
  }

  final List<(SentencePiece, String)> pieces = [];
  pieces.add((SentencePiece.subject_verb, english.translateVerb(verb.second, subjectNoun?.second)));

  final ablativeNoun = getNearestGeneralNoun(accounting, verb.first, caze: Case.abl);
  if (ablativeNoun != null) {
    accounting.accountFor(ablativeNoun.first);
    pieces.add((SentencePiece.indirectObject, "by/from/with ${ablativeNoun.second.properConsideringPrimaryTranslation}"));
  }

  final accusativeNoun = getNearestGeneralNoun(accounting, verb.first, caze: Case.acc);
  if (accusativeNoun != null) {
    accounting.accountFor(accusativeNoun.first);
    pieces.add((SentencePiece.object, accusativeNoun.second.properConsideringPrimaryTranslation));
  }

  pieces.sort(((a, b) => a.$1.ordering.compareTo(b.$1.ordering)));
  final translatedSentence = pieces.map((e) => e.$2).join(" ").replaceAll("  ", " "); // deduplicate spaces

  if (accounting.isNotFullyAccountedFor) {
    print("${Fore.LIGHTBLACK_EX}${Style.DIM}>> accounting: ${accounting.accountingSummary}${Fore.LIGHTBLACK_EX} would be: `$translatedSentence`${Style.RESET_ALL}");
    return null;
  }
  return translatedSentence;
}

String? superParse(Sentence sentence) {
  for (final parser in [accountingBased/*, standaloneVerb, verbWithNominative*/]) {
    print("${Fore.LIGHTBLACK_EX}${Style.DIM}> trying parser: ${parser.name}${Style.RESET_ALL}");
    final result = parser.call(sentence);
    if (result != null) return result;
  }
  return null;
}
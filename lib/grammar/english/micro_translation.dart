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
import 'package:discipulus/grammar/latin/adverb.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/verb.dart';

String _appendE(String original, String suffix) {
  if (original.endsWith("e")) {
    return original + suffix;
  } else if (original.endsWith("y")) {
    return "${original.substring(0, original.length - 1)}ie$suffix";
  } else {
    return "${original}e$suffix";
  }
}

String applyComparison(String adjectiveTranslation, ComparisonType comparison, {bool stripLY = false}) {
  switch (comparison) {
    case ComparisonType.pos:
      return adjectiveTranslation;
    case ComparisonType.comp:
      if (stripLY && adjectiveTranslation.endsWith("ly")) {
        adjectiveTranslation = adjectiveTranslation.substring(0, adjectiveTranslation.length - 2);
      }
      return _appendE(adjectiveTranslation, "r");
    case ComparisonType.Super:
      if (stripLY && adjectiveTranslation.endsWith("ly")) {
        adjectiveTranslation = adjectiveTranslation.substring(0, adjectiveTranslation.length - 2);
      }
      return _appendE(adjectiveTranslation, "st");
    default:
      return adjectiveTranslation;
  }
}

String _conjugateToBe(Person person) {
  final singular = !person.plural;
  switch (person.person) {
    case 1:
      return singular ? "am": "are";
    case 2:
      return singular ? "are": "are";
    case 3:
      return singular ? "is" : "are";
  }
  return "";
}

String translateVerb(Verb verb, [Noun? subject]) {
  String out = "";

  final person = verb.person.person;
  final plural = verb.person.plural;
  switch (person) {
    case 1:
      out += plural ? "we" : "I";
      break;
    case 2:
      out += plural ? "y'all" : "you";
      break;
    case 3:
      out += (subject != null && subject.plural == plural ? subject.properConsideringPrimaryTranslation : null) ?? (plural ? "they" : "he/she/it");
      break;
  }
  out += " ";
  if (verb.isToBe) {
    out += _conjugateToBe(verb.person);
    if (verb is ModifiedVerb) {
      if (verb.adverb.translateBeforeVerb) {
        out = "${verb.adverb.primaryTranslation} $out";
      } else {
        out += " ${verb.adverb.primaryTranslation}";
      }
    }
  } else if (person == 3 && !plural) {
    out += verb.primaryPluralTranslation;
  } else {
    out += verb.primaryTranslation;
  }

  return out;
}

void printTranslationTable(Verb verb) {
  final Noun bob = Noun.bob;
  Map<Person, String> table = {
    for (final person in Person.variants())
      person: translateVerb(verb.copyWith(person: person), Noun.bob)
  };
  final int width = table.values.map((s) => s.length).max;
  /* format:
  (1st singular form) | (1st plural form)
  (2nd singular form) | (2nd plural form)
  (3rd singular form) | (3rd plural form)
   */
  print("┌${"─" * (width + 2)}┬${"─" * (width + 2)}┐");
  for (int i = 1; i <= 3; i++) {
    final singular = Person(person: i, plural: false);
    final plural = Person(person: i, plural: true);
    print("│ ${table[singular]!.padRight(width)} │ ${table[plural]!.padRight(width)} │");
    if (i != 3) {
      print("├${"─" * (width + 2)}┼${"─" * (width + 2)}┤");
    }
  }
  print("└${"─" * (width + 2)}┴${"─" * (width + 2)}┘");
}
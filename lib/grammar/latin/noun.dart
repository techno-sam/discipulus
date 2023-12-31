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

// https://mk270.github.io/whitakers-words/programme.html
import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/english/micro_translation.dart';
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/utils/colors.dart';

import 'adjective.dart';
import 'verb.dart';

enum Case {
  nom("Nominative"),
  gen("Genitive"),
  dat("Dative"),
  acc("Accusative"),
  abl("Ablative")
  ;

  final String description;
  const Case(this.description);

  static Case? decode(String str) {
    str = str.toLowerCase().trim();
    return Case.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }

  static Iterable<Pair<Case, bool>> get allCases {
    return [false, true].map((b) => Case.values.map((c) => Pair(c, b))).expand((e) => e);
  }
}

enum Gender {
  x("All, none, unknown"),
  m("Masculine"),
  f("Feminine"),
  n("Neuter"),
  c("Common (masc and/or fem)")
  ;

  String get pronoun {
    return switch (this) {
      Gender.x => "he/she/it",
      Gender.m => "he",
      Gender.f => "she",
      Gender.n => "they/it",
      Gender.c => "he/she",
    };
  }

  bool equals(Gender other) {
    return this == other || this == x || other == x
        || (this == c && (other == m || other == f))
        || (other == c && (this == m || this == f));
  }

  final String description;
  const Gender(this.description);

  static Gender? decode(String str) {
    str = str.toLowerCase().trim();
    return Gender.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}

class Noun extends Word {
  static final Noun bob = Noun.allTheParts(
    caze: Case.nom,
    plural: false,
    gender: Gender.m,
    parts: const Couple("Bob", "Bob"),
    translations: const [
      ["Bob"]
    ],
    isProper: true
  );

  static final Noun bobAndJoe = Noun.allTheParts(
      caze: Case.nom,
      plural: true,
      gender: Gender.m,
      parts: const Couple("Bob et Joe", "Bob et Joe"),
      translations: const [
        ["Bob and Joe"]
      ],
      isProper: true
  );

  late final Case _caze;
  late final bool _plural;
  late final Gender _gender;
  late final Couple<String> _parts;
  late final List<List<String>> _translations;
  late final bool _isProper;

  Case get caze => _caze;
  bool get plural => _plural;
  Gender get gender => _gender;
  Couple<String> get parts => _parts;
  List<List<String>> get translations => _translations;
  bool get isProper => _isProper;

  String get primaryTranslation => pluralizeNoun(_translations[0][0], plural);
  String get properConsideringPrimaryTranslation => isProper ? primaryTranslation.capitalize : "the $primaryTranslation";

  String verbProperConsideringPrimaryTranslation(Verb verb) {
    if (isProper) {
      return primaryTranslation.capitalize;
    } else if (!(verb.isToBe && caze == Case.nom && plural)) {
      return "${verb.isToBe ? "a" : "the"} $primaryTranslation";
    } else {
      return primaryTranslation;
    }
  }

  Noun.allTheParts({
    required Case caze,
    required bool plural,
    required Gender gender,
    required Couple<String> parts,
    required List<List<String>> translations,
    bool isProper = false
  }): _caze = caze, _plural = plural, _gender = gender, _parts = parts, _translations = translations, _isProper = isProper;

  Noun.lines({required L01Noun line01, required L02Noun line02, required L03Common line03}) {
    _caze = line01.caze;
    _plural = line01.plural;
    _gender = line01.gender;
    assert(line01.gender == line02.gender);
    _parts = line02.parts;
    _translations = line03.translations;
    _isProper = false;
  }

  Noun.pronounLines({required L01Pronoun line01, required L02Pronoun line02, required L03Common line03}) {
    _caze = line01.caze;
    _plural = line01.plural;
    _gender = line01.gender;
    _parts = Couple(line01.split, line01.split);
    _translations = line03.translations;
    _isProper = true;
  }

  @override
  PartsOfSpeech get pos => PartsOfSpeech.noun;

  @override
  String toString() {
    return "Noun[${parts.first} ${parts.second}] ${caze.toString().padRight(16)} ${plural ? 'P' : 'S'} $gender -> $properConsideringPrimaryTranslation";
  }

  @override
  String toColoredString() {
    return "${Fore.BLUE}${toString()}${Fore.RESET}";
  }

  bool canModify(Adjective adjective) {
    if (isProper) throw "Modifying a proper noun is not (yet) supported";
    return adjective.plural == plural && adjective.gender.equals(gender) && adjective.caze == caze;
  }
  
  Noun? modify(Adjective adjective) {
    if (!canModify(adjective)) return null;
    return ModifiedNoun.allTheParts(
      caze: caze,
      plural: plural,
      gender: gender,
      parts: parts,
      translations: translations,
      isProper: isProper,
      adjectives: [adjective]
    );
  }
}
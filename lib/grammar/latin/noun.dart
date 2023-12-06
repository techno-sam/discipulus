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
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/utils/colors.dart';

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
}

enum Gender {
  x("All, none, unknown"),
  m("Masculine"),
  f("Feminine"),
  n("Neuter"),
  c("Common (masc and/or fem)")
  ;

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

class Noun extends PartOfSpeech {
  static final Noun bob = Noun._(
    caze: Case.nom,
    plural: false,
    gender: Gender.m,
    parts: const Couple("Bob", "Bob"),
    translations: const [
      ["Bob"]
    ],
    isProper: true
  );

  static final Noun bobAndJoe = Noun._(
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

  String get primaryTranslation => _translations[0][0];
  String get properConsideringPrimaryTranslation => isProper ? primaryTranslation.capitalize : "the $primaryTranslation";

  Noun._({
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
}
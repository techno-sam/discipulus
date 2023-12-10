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
import 'package:discipulus/grammar/english/micro_translation.dart';
import 'package:discipulus/utils/colors.dart';

import 'lines.dart';
import 'noun.dart';

enum ComparisonType {
  x("All, none, unknown"),
  pos("Positive"),
  comp("Comparative"),
  Super("Superlative"), // ignore: constant_identifier_names
  ;
  final String description;
  const ComparisonType(this.description);

  static ComparisonType? decode(String str) {
    str = str.toLowerCase().trim();
    return ComparisonType.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}

class Adjective extends Word {
  late final Case _caze;
  late final bool _plural;
  late final Gender _gender;
  late final List<String> _parts;
  late final List<List<String>> _translations;
  late final ComparisonType _comparisonType;

  Case get caze => _caze;
  bool get plural => _plural;
  Gender get gender => _gender;
  List<String> get parts => _parts;
  List<List<String>> get translations => _translations;
  ComparisonType get comparisonType => _comparisonType;

  String get primaryTranslation => applyComparison(_translations[0][0], comparisonType);

  Adjective.allTheParts({
    required Case caze,
    required bool plural,
    required Gender gender,
    required List<String> parts,
    required List<List<String>> translations,
    required ComparisonType comparisonType
  }): _caze = caze, _plural = plural, _gender = gender, _parts = parts, _translations = translations, _comparisonType = comparisonType;

  Adjective.lines({required L01Adjective line01, required L02Adjective line02, required L03Common line03}) {
    _caze = line01.caze;
    _plural = line01.plural;
    _gender = line01.gender;
    _parts = line02.parts;
    _translations = line03.translations;
    _comparisonType = line01.comparisonType;
  }

  @override
  PartsOfSpeech get pos => PartsOfSpeech.adjective;

  @override
  String toString() {
    return "Adjective[${parts[0]} ${parts[1]}] ${caze.toString().padRight(16)} ${plural ? 'P' : 'S'} $gender $comparisonType -> $primaryTranslation";
  }

  @override
  String toColoredString() {
    return "${Fore.CYAN}${toString()}${Fore.RESET}";
  }
}

class ModifiedNoun extends Noun {
  final List<Adjective> adjectives;
  ModifiedNoun.allTheParts({
    required super.caze, required super.plural, required super.gender,
    required super.parts, required super.translations, super.isProper,
    required this.adjectives
  }) : super.allTheParts();

  @override
  String get primaryTranslation => "${adjectives.map((a) => a.primaryTranslation).join(" ")} ${super.primaryTranslation}";

  @override
  Noun? modify(Adjective adjective) {
    if (!canModify(adjective)) return null;
    return ModifiedNoun.allTheParts(
        caze: caze,
        plural: plural,
        gender: gender,
        parts: parts,
        translations: translations,
        isProper: isProper,
        adjectives: [...adjectives, adjective]
    );
  }

  @override
  String toString() {
    final String adjectiveString = adjectives.map((a) => "${a.primaryTranslation}(${a.comparisonType.name})").join(", ");
    return "ModifiedNoun[${parts.first} ${parts.second}] ${caze.toString().padRight(16)} ${plural ? 'P' : 'S'} $gender [$adjectiveString] -> $properConsideringPrimaryTranslation";
  }

  @override
  String toColoredString() {
    return "${Fore.LIGHTBLUE_EX}${toString()}${Fore.RESET}";
  }
}
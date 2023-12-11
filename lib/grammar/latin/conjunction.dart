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
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/grammar/latin/verb.dart';
import 'package:discipulus/utils/colors.dart';

import 'noun.dart';

enum ConjunctionType {
  et("and")
  ;
  final String translation;

  const ConjunctionType(this.translation);
}

class Conjunction extends Word {
  late final ConjunctionType _type;

  ConjunctionType get type => _type;

  Conjunction({required ConjunctionType type}): _type = type;

  @override
  PartsOfSpeech get pos => PartsOfSpeech.conjunction;

  @override
  String toString() {
    return "Conjunction[${_type.name}] -> ${_type.translation}";
  }

  @override
  String toColoredString() {
    return "${Fore.GREEN}${toString()}${Fore.RESET}";
  }

  static Conjunction? parse(String str) {
    for (final type in ConjunctionType.values) {
      if (type.name.toLowerCase() == str.toLowerCase()) {
        return Conjunction(type: type);
      }
    }
    return null;
  }

  bool canMerge(Noun a, Noun b) {
    return a.caze == b.caze;
  }

  Noun? merge(Noun a, Noun b) {
    if (!canMerge(a, b)) return null;
    return CompoundNoun(a, b);
  }
}

class CompoundNoun implements Noun {
  final Noun _a;
  final Noun _b;

  const CompoundNoun(Noun a, Noun b): _a = a, _b = b;

  @override
  bool canModify(Adjective adjective) {
    return false; // compounds should only be created post-adjective application
  }

  @override
  Case get caze => _a.caze;

  @override
  Gender get gender => (_a.gender == _b.gender) ? _a.gender : Gender.c;

  @override
  bool get isProper => true;

  @override
  Noun? modify(Adjective adjective) {
    return null;
  }

  @override
  Couple<String> get parts => Couple("${_a.parts.first}&${_b.parts.first}", "${_a.parts.second}&${_b.parts.second}");

  @override
  bool get plural => true;

  @override
  PartsOfSpeech get pos => PartsOfSpeech.noun;

  @override
  List<List<String>> get translations => throw UnimplementedError();

  @override
  String get primaryTranslation => "${_a.primaryTranslation} and ${_b.primaryTranslation}";

  @override
  String get properConsideringPrimaryTranslation => "${_a.properConsideringPrimaryTranslation} and ${_b.properConsideringPrimaryTranslation}";

  @override
  String verbProperConsideringPrimaryTranslation(Verb verb) {
    return "${_a.verbProperConsideringPrimaryTranslation(verb)} and ${_b.verbProperConsideringPrimaryTranslation(verb)}";
  }

  @override
  String toColoredString() {
    return "${Fore.LIGHTGREEN_EX}${toString()}${Fore.RESET}";
  }

  @override
  String toString() {
    return "CompoundNoun[${parts.first} ${parts.second}] ${caze.toString().padRight(16)} ${plural ? 'P' : 'S'} $gender -> $properConsideringPrimaryTranslation";
  }
}
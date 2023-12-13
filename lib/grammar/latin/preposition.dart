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
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/utils/colors.dart';

import 'noun.dart';
import 'verb.dart';

class Preposition extends Word {
  late final String _word;
  late final Case _caze;
  late final List<List<String>> _translations;

  String get word => _word;
  Case get caze => _caze;
  List<List<String>> get translations => _translations;
  String get primaryTranslation => _translations[0][0];

  Preposition({required String word, required Case caze, required List<List<String>> translations}):
        _word = word, _caze = caze, _translations = translations;

  Preposition.lines({required L01Preposition line01, required L02Preposition line02, required L03Common line03}) {
    assert(line01.caze == line02.caze);
    _word = line01.word;
    _caze = line01.caze;
    _translations = line03.translations;
  }

  @override
  PartsOfSpeech get pos => PartsOfSpeech.preposition;

  @override
  String toColoredString() {
    return "${Fore.YELLOW}${toString()}${Fore.RESET}";
  }

  @override
  String toString() {
    return "Preposition[$word] $caze -> $primaryTranslation}";
  }

  bool canPrepose(Noun noun) {
    return noun.caze == caze;
  }

  Noun? prepose(Noun noun) {
    if (!canPrepose(noun)) return null;
    return PrepositionedNoun(noun, this);
  }
}

class PrepositionedNoun extends Word implements Noun {
  late final Noun _wrapped;
  late final Preposition _preposition;

  Noun get wrapped => _wrapped;
  Preposition get preposition => _preposition;

  PrepositionedNoun(Noun wrapped, Preposition preposition) : _wrapped = wrapped, _preposition = preposition;

  @override
  String get properConsideringPrimaryTranslation => "${preposition.primaryTranslation} ${wrapped.properConsideringPrimaryTranslation}";

  @override
  String verbProperConsideringPrimaryTranslation(Verb verb) {
    return "${preposition.primaryTranslation} ${wrapped.verbProperConsideringPrimaryTranslation(verb)}";
  }

  @override
  String toColoredString() {
    return "${Fore.LIGHTBLUE_EX}${toString()}${Fore.RESET}";
  }

  @override
  String toString() {
    return "PrepositionedNoun[${preposition.word}][${parts.first} ${parts.second}] ${caze.toString().padRight(16)} ${plural ? 'P' : 'S'} $gender -> $properConsideringPrimaryTranslation";
  }

  @override
  bool canModify(Adjective adjective) {
    return false; // too late in the pipeline
  }

  @override
  Case get caze => wrapped.caze;

  @override
  Gender get gender => wrapped.gender;

  @override
  bool get isProper => wrapped.isProper;

  @override
  Noun? modify(Adjective adjective) {
    return null;
  }

  @override
  Couple<String> get parts => wrapped.parts;

  @override
  bool get plural => wrapped.plural;

  @override
  PartsOfSpeech get pos => wrapped.pos;

  @override
  String get primaryTranslation => wrapped.primaryTranslation;

  @override
  List<List<String>> get translations => wrapped.translations;
}
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

import 'package:discipulus/grammar/english/micro_translation.dart';
import 'package:discipulus/grammar/latin/adjective.dart';
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/utils/colors.dart';

import 'verb.dart';

class Adverb extends Word {
  late final String _word;
  late final ComparisonType _comparisonType;
  late final List<String> _parts;
  late final List<List<String>> _translations;

  String get word => _word;
  ComparisonType get comparisonType => _comparisonType;
  List<String> get parts => _parts;
  List<List<String>> get translations => _translations;
  String get primaryTranslation => applyComparison(_translations[0][0], comparisonType, stripLY: true);

  bool get translateBeforeVerb => _parts.length == 1;

  Adverb({required String word, required ComparisonType comparisonType,
    required List<String> parts, required List<List<String>> translations}):
        _word = word, _comparisonType = comparisonType, _parts = parts,
        _translations = translations {
    assert (_parts.length == 1 || parts.length == 3);
  }

  Adverb.lines({required L01Adverb line01, required L02Adverb line02, required L03Common line03}) {
    _word = line01.word;
    _comparisonType = line01.comparisonType;
    _parts = line02.parts;
    _translations = line03.translations;

    assert (_parts.length == 1 || parts.length == 3);
  }

  @override
  PartsOfSpeech get pos => PartsOfSpeech.adverb;

  @override
  String toColoredString() {
    return "${Fore.RED}${toString()}${Fore.RESET}";
  }

  @override
  String toString() {
    return "Adverb[$word] $comparisonType -> $primaryTranslation";
  }
}

class ModifiedVerb extends Word implements Verb {
  late final Verb _verb;
  late final Adverb _adverb;

  Verb get verb => _verb;
  Adverb get adverb => _adverb;

  ModifiedVerb({required Verb verb, required Adverb adverb}):
        _verb = verb, _adverb = adverb;

  @override
  PartsOfSpeech get pos => PartsOfSpeech.verb;

  @override
  String toColoredString() {
    return "${Fore.RED}${toString()}${Fore.RESET}";
  }

  @override
  String toString() {
    return "ModifiedVerb[${verb.principleParts[0]} ${verb.principleParts[2]}] by [${adverb.parts.join(", ")}] -> $primaryTranslation";
  }

  @override
  Verb copyWith({Tense? tense, Person? person, Mood? mood, String? principleParts, String? translations, VerbKind? verbKind}) {
    return ModifiedVerb(verb: verb.copyWith(tense: tense, person: person, mood: mood, principleParts: principleParts, translations: translations, verbKind: verbKind), adverb: adverb);
  }

  @override
  bool get isToBe => verb.isToBe;

  @override
  Mood get mood => verb.mood;

  @override
  Person get person => verb.person;

  @override
  String get primaryTranslation => adverb.translateBeforeVerb
      ? "${adverb.primaryTranslation} ${verb.primaryTranslation}"
      : "${verb.primaryTranslation} ${adverb.primaryTranslation}";

  @override
  String get primaryPluralTranslation => adverb.translateBeforeVerb
      ? "${adverb.primaryTranslation} ${verb.primaryPluralTranslation}"
      : "${verb.primaryPluralTranslation} ${adverb.primaryTranslation}";

  @override
  List<String> get principleParts => verb.principleParts;

  @override
  Tense get tense => verb.tense;

  @override
  List<List<String>> get translations => verb.translations;

  @override
  VerbKind get verbKind => verb.verbKind;
}
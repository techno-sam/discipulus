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

import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/utils/colors.dart';

enum Tense {
  pres("Present"),
/*  impf("Imperfect"),
  fut("Future"),
  perf("Perfect"),
  plup("Plu-Perfect"),
  futp("Future Perfect")*/ // don't want to deal with all of these right now
  ;

  final String description;
  const Tense(this.description);

  static Tense? decode(String str) {
    str = str.toLowerCase().trim();
    return Tense.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}

enum VerbKind {
  x("All, none, unknown"),
/*  to_be("To be"),
  to_being("To be (compounds)"),
  gen("taking genitive"),
  dat("taking dative"),
  abl("taking ablative"),*/
  trans("transitive"),
  intrans("intransitive"),
/*  impers("impersonal"),*/
  dep("deponent"),
/*  semidep("semi-deponent"),
  perfdep("perfect deponent"),*/
  ;

  final String description;
  const VerbKind(this.description);

  static VerbKind? decode(String str) {
    str = str.toLowerCase().trim();
    return VerbKind.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}

class Person {
  static final any = Person._any();
  final int person;
  final bool plural;
  late final bool _isAny;

  bool get isAny => _isAny;

  Person({required this.person, required this.plural}) {
    assert(person >= 1 && person <= 3, "Invalid person");
    _isAny = false;
  }

  Person._any() : person = 0, plural = false, _isAny = true;

  @override
  String toString() {
    return "$person${plural ? 'P' : 'S'}";
  }

  @override
  int get hashCode => Object.hash(person, plural, _isAny);

  @override
  bool operator ==(covariant Person other) {
    if (super == other) return true;
    return person == other.person && plural == other.plural && _isAny == other._isAny;
  }

  static Iterable<Person> variants() {
    return [
      for (bool plural in [false, true])
        for (int i = 1; i <= 3; i++)
          Person(person: i, plural: plural),
    ];
  }
}

// note: for now, only doing indicative and imperative
// note: for now, only handling active
enum Mood {
  ind("Indicative"), // indicative
  inf("Infinitive"), // infinitive
  ;

  final String description;
  const Mood(this.description);

  static Mood? decode(String str) {
    str = str.toLowerCase().trim();
    return Mood.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}

class Verb extends Word {
  late final Tense _tense; // meaningless for infinitives
  late final Person _person; // meaningless for infinitives
  late final Mood _mood;
  late final List<String> _principleParts;
  late final List<List<String>> _translations;
  late final VerbKind _verbKind;

  Tense get tense => _tense;
  Person get person => _person;
  Mood get mood => _mood;
  List<String> get principleParts => _principleParts;
  List<List<String>> get translations => _translations;
  VerbKind get verbKind => _verbKind;
  bool get isToBe => principleParts[0] == "sum" && principleParts[1] == "esse"
      && principleParts[2] == "fui" && principleParts[3] == "futurus";

  String get primaryTranslation => (mood == Mood.inf ? "to " : "") + _translations[0][0];

  Verb({required Tense tense, required Person person, required Mood mood,
    required String principleParts, required String translations,
    required VerbKind verbKind}) : _mood = mood, _person = person,
        _tense = tense, _verbKind = verbKind {
    _principleParts = principleParts.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList(growable: false);

    Iterable<String> meanings = translations.split(";").map((s) => s.trim());
    _translations = meanings.map(
            (s) => s
                .split(RegExp(r"[,/]"))
                .map((s) => s.trim())
                .toList(growable: false)
    ).toList(growable: false);
  }

  Verb.lines({required L01Verb line01, required L02Verb line02, required L03Common line03}) {
    _tense = line01.tense;
    _person = line01.person;
    _mood = line01.mood;
    _principleParts = line02.parts;
    _verbKind = line02.verbKind;
    _translations = line03.translations;
  }

  String get primaryPluralTranslation => "${primaryTranslation}s";

  @override
  String toString() {
    return "Verb[${principleParts[0]} ${principleParts[1]}]${verbKind == VerbKind.x ? "" : verbKind} $tense $mood $person -> $primaryTranslation";
  }

  @override
  PartsOfSpeech get pos => PartsOfSpeech.verb;

  @override
  String toColoredString() {
    return "${Fore.LIGHTRED_EX}${toString()}${Fore.RESET}";
  }

  Verb copyWith({Tense? tense, Person? person, Mood? mood, String? principleParts, String? translations, VerbKind? verbKind}) {
    return Verb(
      tense: tense ?? _tense,
      person: person ?? _person,
      mood: mood ?? _mood,
      principleParts: principleParts ?? _principleParts.join(", "),
      translations: translations ?? _translations.map((l) => l.join(", ")).join("; "),
      verbKind: verbKind ?? _verbKind
    );
  }
}
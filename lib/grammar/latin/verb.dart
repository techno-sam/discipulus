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

class Person {
  final int person;
  final bool plural;

  Person({required this.person, required this.plural}) {
    assert(person >= 1 && person <= 3, "Invalid person");
  }

  @override
  String toString() {
    return "$person${plural ? 'P' : 'S'}";
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

class Verb {
  late final Tense _tense; // meaningless for infinitives
  late final Person _person; // meaningless for infinitives
  late final Mood _mood;
  late final List<String> _principleParts;
  late final List<List<String>> _translations;

  Tense get tense => _tense;
  Person get person => _person;
  Mood get mood => _mood;
  List<String> get principleParts => _principleParts;
  List<List<String>> get translations => _translations;

  String get primaryTranslation => _translations[0][0];

  Verb({required Tense tense, required Person person, required Mood mood,
    required String principleParts, required String translations}) : _mood = mood, _person = person, _tense = tense {
    _principleParts = principleParts.split(",").map((s) => s.trim()).where((s) => s.isNotEmpty).toList(growable: false);

    Iterable<String> meanings = translations.split(";").map((s) => s.trim());
    _translations = meanings.map(
            (s) => s
                .split(RegExp(r"[,/]"))
                .map((s) => s.trim())
                .toList(growable: false)
    ).toList(growable: false);
  }

  factory Verb.fromWordsLines(String blob) {
    bool filledInFromLine01 = false;
    Tense? tense;
    Person? person;
    Mood? mood;
    bool filledInFromLine02 = false;
    String? principleParts;

    for (String line in blob.split("\n")) {
      line = line.trim();
      List<String> parts = line.split(" ").map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      if (line.startsWith("01")) { // note: Pearse Codes must be enabled for parsing to work
        if (filledInFromLine01) continue;
        if (parts[2] != "V") continue;
        Tense? tense_ = Tense.decode(parts[5]);
        Mood? mood_ = Mood.decode(parts[7]);
        if (mood_ == Mood.inf) {
          parts[9] = "S";
          parts[8] = "1";
        }
        assert(parts[9] == "S" || parts[9] == "P", "Unexpected person plurality ${parts[9]}");
        int personNum = int.parse(parts[8]);
        Person person_ = Person(person: personNum, plural: parts[9] == "P");
        if (tense_ != null && mood_ != null) {
          tense = tense_;
          mood = mood_;
          person = person_;
          filledInFromLine01 = true;
          continue;
        }
      } else if (line.startsWith("02")) {
        if (!filledInFromLine01) continue;
        if (filledInFromLine02) continue;
        List<String> pp = [];
        for (int i = 1; i <= 4; i++) {
          pp.add(parts[i].replaceAll(",", "").trim());
          if (!parts[i].contains(",")) break;
        }
        principleParts = pp.join(", ");
        filledInFromLine02 = true;
        continue;
      } else if (line.startsWith("03")) {
        if (!filledInFromLine01 || !filledInFromLine02) continue;
        String translations = line.replaceFirst("03", "").trim();
        if (tense == null || mood == null || person == null || principleParts == null) {
          throw "Impossible state, what???";
        }
        return Verb(
          tense: tense,
          mood: mood,
          person: person,
          principleParts: principleParts,
          translations: translations
        );
      }
    }
    throw "Unable to parse verb from: ```$blob```";
  }

  @override
  String toString() {
    return "Verb[${principleParts[0]} ${principleParts[1]}] $tense $mood $person -> $primaryTranslation";
  }
}
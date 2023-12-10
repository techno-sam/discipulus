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

/*
Types of lines:
01 Verb: `01 voc.at               V      1 1 PRES ACTIVE  IND 3 S`
02 Verb: `02 voco, vocare, vocavi, vocatus  V (1st)   [XXXAX]`
03 Common: `03 call, summon; name; call upon;` (no regex needed)

01 Noun: `01 puell.a              N      1 1 NOM S F`
02 Noun: `02 puella, puellae  N (1st) F   [XXXBO]`
03 Common: `03 girl, (female) child/daughter; maiden; young woman/wife; sweetheart; slavegirl;` (no regex needed)

There can be multiple 01-type lines leading up to each 02-03 pair
 */

import 'package:discipulus/grammar/latin/verb.dart' show Mood, Person, Tense, Verb;
import 'package:discipulus/grammar/latin/noun.dart' show Case, Gender, Noun;
import 'package:discipulus/grammar/latin/regex.dart' show re;
import 'package:discipulus/datatypes.dart';

enum PartsOfSpeech {
  verb,
  noun
}

abstract class Word {
  PartsOfSpeech get pos;

  String toColoredString();
}

List<Line> parseToLines(String text) {
  List<Line> out = [];
  for (String line in text.split("\n")) {
    Line? parsed = Line.parse(line.trim());
    if (parsed != null) out.add(parsed);
  }
  return out;
}

enum _Mode {
  none,
  collectingNoun,
  collectingVerb
}

List<Word> parseToPOS(List<Line> lines) {
  List<Word> out = [];
  List<L01Noun> nounBits = [];
  List<L01Verb> verbBits = [];

  _Mode mode = _Mode.none;
  final PeekableIterator<Line> iter = lines.iterator.peekable();
  while (iter.moveNext()) {
    final line = iter.current;
    switch (mode) {
      case _Mode.none:
        if (line is L01Noun) {
          nounBits = [line];
          verbBits = [];
          mode = _Mode.collectingNoun;
        } else if (line is L01Verb) {
          nounBits = [];
          verbBits = [line];
          mode = _Mode.collectingVerb;
        } else {
          print("Unexpected line $line during mode $mode");
        }
        break;
      case _Mode.collectingNoun:
        if (line is L01Noun) {
          nounBits.add(line);
        } else if (line is L02Noun && iter.canPeek()) {
          final Line next = iter.peeked;
          if (next is L03Common) {
            iter.moveNext();
            for (final bit in nounBits) {
              out.add(Noun.lines(line01: bit, line02: line, line03: next));
            }
          } else {
            print("Incorrect next line $line");
          }
          mode = _Mode.none;
          nounBits = [];
          verbBits = [];
        } else {
          print("Failed to handle line: $line");
        }
        break;
      case _Mode.collectingVerb:
        if (line is L01Verb) {
          verbBits.add(line);
        } else if (line is L02Verb && iter.canPeek()) {
          final Line next = iter.peeked;
          if (next is L03Common) {
            iter.moveNext();
            for (final bit in verbBits) {
              out.add(Verb.lines(line01: bit, line02: line, line03: next));
            }
          } else {
            print("Incorrect next line $line");
          }
          mode = _Mode.none;
          nounBits = [];
          verbBits = [];
        } else {
          print("Failed to handle line: $line");
        }
        break;
    }
  }
  return out;
}

class Line {
  final String original;

  const Line({required this.original});

  static Line? parse(String text) {
    const List<Line? Function(String)> parsers = [
      L01Verb.parse,
      L02Verb.parse,
      L01Noun.parse,
      L02Noun.parse,
      L03Common.parse,
    ];
    for (Line? Function(String) parser in parsers) {
      Line? parsed = parser(text);
      if (parsed != null) return parsed;
    }
    return null;
  }
}

class L01 extends Line {
  final String split;

  const L01({required super.original, required this.split});
}

class L01Verb extends L01 {
  final Tense tense;
  final Mood mood;
  final Person person;

  const L01Verb({required super.original, required super.split, required this.tense, required this.mood, required this.person});

  static L01Verb? parse(String text) {
    RegExpMatch? match = re.l01verb.firstMatch(text);
    if (match == null) return null;

    String split_ = match.namedGroup("split")!;
    String tense_ = match.namedGroup("tense")!.toLowerCase();
    String mood_ = match.namedGroup("mood")!.toLowerCase();
    int personNum_ = int.parse(match.namedGroup("person_num")!);
    bool personPl_ = match.namedGroup("person_pl")!.toLowerCase() == "p";

    Tense? tense = Tense.decode(tense_);
    Mood? mood = Mood.decode(mood_);
    Person person = Person(person: personNum_, plural: personPl_);
    if (tense == null || mood == null) {
      print("[L01Verb] Tense or mood not found for $text");
      return null;
    }
    return L01Verb(original: text, split: split_, tense: tense, mood: mood, person: person);
  }
}

class L02Verb extends Line {
  final List<String> parts;
  final bool intransitive;

  L02Verb({required super.original, required this.parts, required this.intransitive}) {
    assert(parts.length == 3 || parts.length == 4);
  }

  static L02Verb? parse(String text) {
    RegExpMatch? match = re.l02verb.firstMatch(text);
    if (match == null) return null;

    List<String> parts = match.namedGroup("parts")!.split(", ");
    if (parts.length < 3 || parts.length > 4) {
      print("[L02Verb] Invalid number of parts (${parts.length}) for $text");
      return null;
    }
    return L02Verb(original: text, parts: parts, intransitive: match.namedGroup("intransitive") != null);
  }
}

class L01Noun extends L01 {
  final Case caze; // not a typo, 'case' is a reserved word
  final bool plural;
  final Gender gender;

  const L01Noun({required super.original, required super.split, required this.caze, required this.plural, required this.gender});

  static L01Noun? parse(String text) {
    RegExpMatch? match = re.l01noun.firstMatch(text);
    if (match == null) return null;

    String split_ = match.namedGroup("split")!;
    String case_ = match.namedGroup("case")!.toLowerCase();
    bool plural_ = match.namedGroup("person_pl")!.toLowerCase() == "p";
    String gender_ = match.namedGroup("gender")!.toLowerCase();

    Case? caze = Case.decode(case_);
    Gender? gender = Gender.decode(gender_);
    if (caze == null || gender == null) {
      print("[L01Noun] Case or gender not found for $text");
      return null;
    }
    return L01Noun(original: text, split: split_, caze: caze, plural: plural_, gender: gender);
  }
}

class L02Noun extends Line {
  final Couple<String> parts;
  final Gender gender;
  const L02Noun({required super.original, required this.parts, required this.gender});

  static L02Noun? parse(String text) {
    RegExpMatch? match = re.l02noun.firstMatch(text);
    if (match == null) return null;

    String parts_ = match.namedGroup("parts")!;
    String gender_ = match.namedGroup("gender")!.toLowerCase();

    Couple<String>? parts = parts_.split(", ").tryToCouple();
    Gender? gender = Gender.decode(gender_);

    if (parts == null || gender == null) {
      print("[L02Noun] Parts or gender not found for $text");
      return null;
    }
    return L02Noun(original: text, parts: parts, gender: gender);
  }
}

class L03Common extends Line {
  final List<List<String>> translations;
  String get primaryTranslation => translations[0][0];

  const L03Common({required super.original, required this.translations});

  static L03Common? parse(String text) {
    if (!text.startsWith("03 ")) return null;

    String translationText = text.replaceFirst("03 ", "").trim();

    Iterable<String> meanings = translationText.split(";").map((s) => s.trim());
    List<List<String>> translations = meanings.map(
            (s) => s
            .split(RegExp(r"[,/]"))
            .map((s) => s.trim())
            .toList(growable: false)
    ).where((l) => l.isNotEmpty).toList(growable: false);
    if (translations.isEmpty) {
      print("[L03Common] No translations found for $text");
      return null;
    }
    return L03Common(original: text, translations: translations);
  }
}
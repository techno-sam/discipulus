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

import 'package:discipulus/grammar/latin/preposition.dart';
import 'package:discipulus/grammar/latin/verb.dart' show Mood, Person, Tense, Verb, VerbKind;
import 'package:discipulus/grammar/latin/noun.dart' show Case, Gender, Noun;
import 'package:discipulus/grammar/latin/regex.dart' show re;
import 'package:discipulus/datatypes.dart';

import 'adjective.dart';

enum PartsOfSpeech {
  verb,
  noun,
  adjective,
  conjunction,
  preposition
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
  collectingVerb,
  collectingAdjective,
  collectingPreposition
}

const _printBackup = print;

List<Word> parseToPOS(List<Line> lines, {void Function(String) print = _printBackup}) {
  List<Word> out = [];
  List<dynamic> bits = [];

  _Mode mode = _Mode.none;
  final PeekableIterator<Line> iter = lines.iterator.peekable();
  while (iter.moveNext()) {
    final line = iter.current;
    switch (mode) {
      case _Mode.none:
        if (line is L01Noun) {
          bits = [line];
          mode = _Mode.collectingNoun;
        } else if (line is L01Verb) {
          bits = [line];
          mode = _Mode.collectingVerb;
        } else if (line is L01Adjective) {
          bits = [line];
          mode = _Mode.collectingAdjective;
        } else if (line is L01Preposition) {
          bits = [line];
          mode = _Mode.collectingPreposition;
        } else {
          print("Unexpected line $line during mode $mode");
        }
        break;
      case _Mode.collectingNoun:
        if (line is L01Noun) {
          bits.add(line);
        } else if (line is L02Noun && iter.canPeek()) {
          final Line next = iter.peeked;
          if (next is L03Common) {
            iter.moveNext();
            for (final L01Noun bit in bits) {
              out.add(Noun.lines(line01: bit, line02: line, line03: next));
            }
          } else {
            print("Incorrect next line $line");
          }
          mode = _Mode.none;
          bits = [];
        } else {
          print("Failed to handle line: $line");
        }
        break;
      case _Mode.collectingVerb:
        if (line is L01Verb) {
          bits.add(line);
        } else if (line is L02Verb && iter.canPeek()) {
          Line next = iter.peeked;
          while (next is L02Verb && iter.canPeek()) {
            iter.moveNext();
            next = iter.peeked;
          }
          if (next is L03Common) {
            iter.moveNext();
            for (final L01Verb bit in bits) {
              out.add(Verb.lines(line01: bit, line02: line, line03: next));
            }
          } else {
            print("Incorrect next line $line");
          }
          mode = _Mode.none;
          bits = [];
        } else {
          print("Failed to handle line: $line");
        }
        break;
      case _Mode.collectingAdjective:
        if (line is L01Adjective) {
          bits.add(line);
        } else if (line is L02Adjective && iter.canPeek()) {
          final Line next = iter.peeked;
          if (next is L03Common) {
            iter.moveNext();
            for (final L01Adjective bit in bits) {
              out.add(Adjective.lines(line01: bit, line02: line, line03: next));
            }
          } else {
            print("Incorrect next line $line");
          }
          mode = _Mode.none;
          bits = [];
        } else {
          print("Failed to handle line: $line");
        }
        break;
      case _Mode.collectingPreposition:
        if (line is L01Preposition) {
          bits.add(line);
        } else if (line is L02Preposition && iter.canPeek()) {
          final Line next = iter.peeked;
          if (next is L03Common) {
            iter.moveNext();
            for (final L01Preposition bit in bits) {
              out.add(Preposition.lines(line01: bit, line02: line, line03: next));
            }
          } else {
            print("Incorrect next line $line");
          }
          mode = _Mode.none;
          bits = [];
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
      L01Adjective.parse,
      L02Adjective.parse,
      L01Preposition.parse,
      L02Preposition.parse,
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

/********/
/* Verb */
/********/

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
  final VerbKind verbKind;

  L02Verb({required super.original, required this.parts, required this.verbKind}) {
    assert(parts.length == 3 || parts.length == 4);
  }

  static L02Verb? parse(String text) {
    RegExpMatch? match = re.l02verb.firstMatch(text);
    if (match == null) return null;

    List<String> parts = match.namedGroup("parts")!.split(", ");
    String verbKind_ = (match.namedGroup("verb_type") ?? "X").toLowerCase();

    VerbKind? verbKind = VerbKind.decode(verbKind_);

    if (parts.length < 3 || parts.length > 4) {
      print("[L02Verb] Invalid number of parts (${parts.length}) for $text");
      return null;
    }
    if (verbKind == null) {
      print("[L02Verb] Verb kind not found for $text");
      return null;
    }
    return L02Verb(original: text, parts: parts, verbKind: verbKind);
  }
}

/********/
/* Noun */
/********/

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

/********/
/* Adjective */
/********/

class L01Adjective extends L01 {
  final Case caze; // not a typo, 'case' is a reserved word
  final bool plural;
  final Gender gender;
  final ComparisonType comparisonType;

  const L01Adjective({required super.original, required super.split, required this.caze, required this.plural, required this.gender, required this.comparisonType});

  static L01Adjective? parse(String text) {
    RegExpMatch? match = re.l01adjective.firstMatch(text);
    if (match == null) return null;

    String split_ = match.namedGroup("split")!;
    String case_ = match.namedGroup("case")!.toLowerCase();
    bool plural_ = match.namedGroup("person_pl")!.toLowerCase() == "p";
    String gender_ = match.namedGroup("gender")!.toLowerCase();
    String comparisonType_ = match.namedGroup("comparison_type")!.toLowerCase();

    Case? caze = Case.decode(case_);
    Gender? gender = Gender.decode(gender_);
    ComparisonType? comparisonType = ComparisonType.decode(comparisonType_);
    if (caze == null || gender == null || comparisonType == null) {
      print("[L01Adjective] Case, gender, or comparison type not found for $text");
      return null;
    }
    return L01Adjective(original: text, split: split_, caze: caze, plural: plural_, gender: gender, comparisonType: comparisonType);
  }
}

class L02Adjective extends Line {
  final List<String> parts;
  L02Adjective({required super.original, required this.parts}) {
    assert(parts.length == 3 || parts.length == 4);
  }

  static L02Adjective? parse(String text) {
    RegExpMatch? match = re.l02adjective.firstMatch(text);
    if (match == null) return null;

    String parts_ = match.namedGroup("parts")!;

    List<String> parts = parts_.split(", ");
    return L02Adjective(original: text, parts: parts);
  }
}

/***************/
/* Preposition */
/***************/

class L01Preposition extends L01 {
  late final Case _caze;

  Case get caze => _caze;
  String get word => split;

  L01Preposition({required super.original, required super.split, required Case caze}): _caze = caze;
  
  static L01Preposition? parse(String text) {
    RegExpMatch? match = re.l01preposition.firstMatch(text);
    if (match == null) return null;

    String split_ = match.namedGroup("word")!;
    String case_ = match.namedGroup("case")!.toLowerCase();

    Case? caze = Case.decode(case_);
    if (caze == null) {
      print("[L01Preposition] Case not found for $text");
      return null;
    }
    return L01Preposition(original: text, split: split_, caze: caze);
  }
}

class L02Preposition extends Line {
  late final Case _caze;

  Case get caze => _caze;

  L02Preposition({required super.original, required Case caze}): _caze = caze;

  static L02Preposition? parse(String text) {
    RegExpMatch? match = re.l02preposition.firstMatch(text);
    if (match == null) return null;

    String case_ = match.namedGroup("case")!.toLowerCase();

    Case? caze = Case.decode(case_);
    if (caze == null) {
      print("[L02Preposition] Case not found for $text");
      return null;
    }
    return L02Preposition(original: text, caze: caze);
  }
}

/***********/
/* Common */
/**********/

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
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
import 'package:discipulus/ffi/words_low_level.dart';
import 'package:discipulus/grammar/latin/adverb.dart';
import 'package:discipulus/grammar/latin/conjunction.dart';
import 'package:discipulus/grammar/latin/proper_names.dart';
import 'package:discipulus/grammar/latin/sentence_parsing/sentence_parsers.dart';
import 'package:discipulus/grammar/latin/sentence_parsing/utils.dart' show applyAdjectives, applyAdverbs, applyConjunctions, applyPrepositions, splitClauses;
import 'package:discipulus/utils/colors.dart';
import 'package:discipulus/utils/print_buffer.dart';
import 'package:discipulus/utils/tuning.dart' as tuning;

import 'lines.dart';
import 'noun.dart';

class Sentence {
  final List<Word> words;
  final String original;

  const Sentence({required this.words, required this.original});

  @override
  String toString() {
    return words.toString();
  }

  String toColoredString() {
    String out = "[";
    for (int i = 0; i < words.length; i++) {
      out += words[i].toColoredString();
      if (i != words.length - 1) {
        out += "${Back.RED}, ${Back.RESET}";
      }
    }
    out += "]${Style.RESET_ALL}";
    return out;
  }

  /// do NOT call .enumerate on this, it will break the accounting system
  List<Word> get unusedWords => words;
  List<Pair<int, Word>> get enumeratedUnusedWords => words.enumerate.toList();

  AccountingSentence makeAccounting() {
    return AccountingSentence(words: words.shallowCopy(), original: original);
  }

  Sentence shallowCopy() {
    return Sentence(words: words.shallowCopy(), original: original);
  }
}

class AccountingSentence extends Sentence {
  late final List<bool> _accountedFor;
  AccountingSentence({required super.words, required super.original}) {
    _accountedFor = List.filled(words.length, false);
  }

  String get accountingSummary => _accountedFor.colorCoded;

  bool isAccountedFor(int index) {
    return _accountedFor[index];
  }

  void accountFor(int index) {
    _accountedFor[index] = true;
  }

  bool get isFullyAccountedFor {
    return _accountedFor.every((b) => b);
  }

  bool get isNotFullyAccountedFor {
    return _accountedFor.any((b) => !b);
  }

  @override
  List<Word> get unusedWords => words.enumerate.where((e) => !isAccountedFor(e.first)).map((e) => e.second).toList();
  @override
  List<Pair<int, Word>> get enumeratedUnusedWords => words.enumerate.where((e) => !isAccountedFor(e.first)).toList();
}

const _printBackup = print;

class SentenceBundle {
  final List<List<Word>> words;
  final String original;

  const SentenceBundle({required this.words, required this.original});

  factory SentenceBundle.fromSentence(String text, {required bool debugMode, void Function(String) print = _printBackup}) {
    final originalText = text;
    WordsLL wordsLL = WordsLL(debugMode: debugMode);
    text = text.toLowerCase();
    List<List<Word>> processedWords = [];

    if (text.contains(",") || text.contains(":") || text.contains(";")) {
      throw ArgumentError.value(text, "text", "Sentence cannot contain punctuation");
    }

    List<String> words = text.split(" ").where((s) => s.isNotEmpty).toList();
    for (String word in words) {
      final List<Noun>? properName = properNames.parse(word);
      if (properName != null && properName.isNotEmpty) {
        processedWords.add(properName);
        continue;
      }

      final String linesText = wordsLL.wordsDefault(word);
      final List<Line> lines = parseToLines(linesText);
      final List<Word> partsOfSpeech = parseToPOS(lines, print: print).where((w) {
        if (tuning.whenDoesNotExist) {
          if (w is Adverb && w.parts[0] == "cum") {
            return false;
          }
        }
        return true;
      }).toList();
      if (partsOfSpeech.isEmpty) {
        final String indentedOutput = linesText.split("\n").map((s) => "> $s").join("\n");
        throw "Word could not be translated: \"$word\"\n$indentedOutput";
      }
      processedWords.add(partsOfSpeech);
    }

    return SentenceBundle(words: processedWords, original: originalText);
  }

  List<Sentence> allPossibleSentences() {
    List<List<Word>> parts = [];
    for (List<Word> word in words) {
      parts.extendVariants(word);
    }

    return parts.map((p) => Sentence(words: p, original: original)).toList();
  }
  
  void printAllPossibilities({bool skipUntranslatable = false}) {
    final PrintBuffer printBuffer = PrintBuffer();
    print("${Style.RESET_ALL}all sentence possibilities:");
    String? firstTranslation;
    final List<String> allTranslations = [];
    for (Sentence s in allPossibleSentences()) {
      printBuffer.clear();
      s = s.shallowCopy();
      applyAdjectives(s);
      applyPrepositions(s);
      applyConjunctions(s);

      List<Sentence> clauses = splitClauses(s);
      clauses.forEach(applyAdverbs);
      List<String?> parsedBits = [];
      List<Noun> superSubjectStack = [];
      for (Pair<int, Sentence> iClause in clauses.enumerate) {
        final i = iClause.first;
        final clause = iClause.second;

        String? parsed = superParse(clause, superSubjectStack, i == 0, print: printBuffer.printSham);
        parsedBits.add(parsed);
      }
      String? parsed;
      if (parsedBits.any((s) => s == null)) {
        parsed = null;
      } else {
        parsed = parsedBits.join(" ");
      }
      firstTranslation ??= parsed;
      if (parsed != null) {
        allTranslations.add(parsed);
      } else if (skipUntranslatable) {
        continue;
      }
      printBuffer.print();
      print("\t${s.toColoredString()} ${Fore.YELLOW}->${Fore.RESET} ${parsed ?? "${Fore.LIGHTMAGENTA_EX}NO TRANSLATION${Fore.RESET}"}");
    }
    print("first translation:");
    print("\t${Style.BRIGHT}$original${Style.RESET_ALL} ${Fore.YELLOW}->${Fore.RESET} ${firstTranslation ?? "${Fore.LIGHTMAGENTA_EX}NO TRANSLATIONS${Fore.RESET}"}");
    if (allTranslations.length > 1) {
      print("other translations:");
      for (String translation in allTranslations.skip(1)) {
        print("\t${Style.BRIGHT}$original${Style.RESET_ALL} ${Fore.YELLOW}->${Fore.RESET} ${translation}");
      }
    }
  }
}
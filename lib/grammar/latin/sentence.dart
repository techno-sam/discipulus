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
import 'package:discipulus/grammar/latin/sentence_parsing/sentence_parsers.dart';
import 'package:discipulus/utils/colors.dart';

import 'lines.dart';

class Sentence {
  final List<PartOfSpeech> words;

  const Sentence({required this.words});

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
}

class SentenceBundle {
  final List<List<PartOfSpeech>> words;

  const SentenceBundle({required this.words});

  factory SentenceBundle.fromSentence(String text, {required bool debugMode}) {
    WordsLL wordsLL = WordsLL(debugMode: debugMode);
    text = text.toLowerCase();
    List<List<PartOfSpeech>> processedWords = [];

    if (text.contains(",") || text.contains(":") || text.contains(";")) {
      throw ArgumentError.value(text, "text", "Sentence cannot contain punctuation");
    }

    List<String> words = text.split(" ").where((s) => s.isNotEmpty).toList();
    for (String word in words) {
      final String linesText = wordsLL.wordsDefault(word);
      final List<Line> lines = parseToLines(linesText);
      final List<PartOfSpeech> partsOfSpeech = parseToPOS(lines);
      processedWords.add(partsOfSpeech);
    }

    return SentenceBundle(words: processedWords);
  }

  List<Sentence> allPossibleSentences() {
    List<List<PartOfSpeech>> parts = [];
    for (List<PartOfSpeech> word in words) {
      parts.extendVariants(word);
    }

    return parts.map((p) => Sentence(words: p)).toList();
  }
  
  void printAllPossibilities() {
    print("${Style.RESET_ALL}all sentence possibilities:");
    for (Sentence s in allPossibleSentences()) {
      print("\t${s.toColoredString()} ${Fore.YELLOW}->${Fore.RESET} ${superParse(s) ?? "${Fore.LIGHTMAGENTA_EX}NO TRANSLATION${Fore.RESET}"}");
    }
  }
}
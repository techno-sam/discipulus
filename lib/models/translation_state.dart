/*
 *     Discipulus
 *     Copyright (C) 2025  Sam Wagenaar
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

import 'dart:async';

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/ffi/words_low_level.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/s.dart';
import 'package:discipulus/grammar/latin/syntax_tree/parser.dart' as parser;
import 'package:flutter/foundation.dart';

class TranslationSuccess {
  final List<Pair<String, S>> sentences;

  TranslationSuccess({required this.sentences});

  List<String> get translations =>
      sentences.map((p) => p.second.translate(null)).toList(growable: false);
}

class TranslationError {
  final dynamic error;

  TranslationError({required this.error});

  @override
  String toString() => error.toString();
}

class TranslationState extends ChangeNotifier {
  final WordsLL _backend = WordsLL(debugMode: kDebugMode);

  String _sourceText = "";
  Either<TranslationSuccess, TranslationError>? _result;

  String get sourceText => _sourceText;
  Either<TranslationSuccess, TranslationError>? get result => _result;

  void setSourceText(String text) {
    _sourceText = text;
    _tryTranslate();
    notifyListeners();
  }

  void _tryTranslate() {
    if (sourceText.isEmpty) {
      _result = null;
      return;
    }

    try {
      final bundle = SentenceBundle.fromSentence(sourceText, backend: _backend);
      final sentences = bundle.allPossibleSentences()
          .map((sentence) {
            String debugText = "";
            void debug(String text) {
              debugText += "$text\n";
            }

            final parsed = runZoned(
              () => parser.parse(sentence, showIntermediate: true),
              zoneSpecification: ZoneSpecification(
                print: (self, parent, zone, line) {
                  debug(line);
                },
              ),
            );

            return Pair(debugText, parsed);
          })
          .where((p) => p.second.nodes.length == 1)
          .map((p) => Pair(p.first, p.second.nodes[0]))
          .whereSecondType<S>()
          .toList(growable: false);
      _result = Either.a(TranslationSuccess(sentences: sentences));
    } catch (e) {
      _result = Either.b(TranslationError(error: e));
    }
  }
}
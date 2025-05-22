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
import 'dart:math';

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/s.dart';
import 'package:discipulus/grammar/latin/syntax_tree/parser.dart' as parser;
import 'package:discipulus/words_invokers/words_invoker.dart';
import 'package:discipulus/utils/compute.dart';
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
  final WordsInvoker _backend = WordsInvoker.create(debugMode: kDebugMode);

  String _sourceText = "";
  Future<Either<TranslationSuccess, TranslationError>>? _result;

  String get sourceText => _sourceText;
  Future<Either<TranslationSuccess, TranslationError>>? get result => _result;

  @override
  void dispose() {
    _backend.dispose();
    super.dispose();
  }

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

    _result = runZoned(
      () => __tryTranslate(),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {},
      ),
    );
  }

  static Pair<String, S>? __tryTranslateSingle(Sentence sentence) {
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

    if (parsed.nodes.length != 1) return null;

    var node0 = parsed.nodes[0];
    if (node0 is! S) return null;

    return Pair(debugText, node0);
  }

  Future<Either<TranslationSuccess, TranslationError>> __tryTranslate() async {
    try {
      final bundle = await SentenceBundle.fromSentenceAsync(sourceText, backend: _backend);

      /*List<Pair<String, S>> translateSentences(SentenceBundle bundle) => bundle.allPossibleSentences()
          .map(__tryTranslateSingle)
          .whereType<Pair<String, S>>()
          .toList(growable: false);*/

      // final sentences = await compute(translateSentences, bundle, debugLabel: "Translate Sentences");

      var allPossibleSentences = bundle.allPossibleSentences();
      final results = await computePooled(
        __tryTranslateSingle,
        allPossibleSentences,
        // max 8 pools, but scale dynamically below that
        poolCount: min(8, (allPossibleSentences.length / 8).ceil()),
      );
      final sentences = results.whereType<Pair<String, S>>().toList(growable: false);

      return Either.a(TranslationSuccess(sentences: sentences));
    } catch (e) {
      return Either.b(TranslationError(error: e));
    }
  }
}
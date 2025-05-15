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

import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/word_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'np.dart';

class P implements SyntaxNode<P> {
  final Preposition _preposition;

  const P(this._preposition);

  Case get caze => _preposition.caze;

  String translate() => _preposition.primaryTranslation;

  @override
  P shallowClone() => P(_preposition);

  @override
  String getDebugLabel() => "P: ${_preposition.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class PP implements SyntaxNode<PP> {
  final P _preposition;
  final NP<dynamic> _noun;

  PP(this._preposition, this._noun) {
    if (_preposition.caze != _noun.caze) {
      throw ArgumentError.value(
        (_preposition.caze, _noun.caze),
        "(preposition.caze, noun.caze)",
        "Preposition and noun must have the same case",
      );
    }
  }

  static bool isValidPair(P preposition, NP<dynamic> noun) =>
      preposition.caze == noun.caze;

  String translate({required Article? article}) {
    return "${_preposition.translate()} ${_noun.translate(article: article)}";
  }

  @override
  PP shallowClone() => PP(_preposition, _noun);

  @override
  String getDebugLabel() => "PP -> ${translate(article: Article.definite)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_preposition, _noun];
}
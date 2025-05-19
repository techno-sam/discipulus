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
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/word_types.dart';

import 'np.dart';

class VInf implements SyntaxNode<VInf> {
  final Verb _verb;

  VInf(this._verb) {
    if (_verb.mood != Mood.inf) {
      throw ArgumentError.value(_verb.mood, "_verb.mood", "Mood must be infinitive");
    }
  }

  Tense get tense => _verb.tense;
  VerbKind get verbKind => _verb.verbKind;

  String translate() => "to ${_verb.primaryTranslation}";

  @override
  VInf shallowClone() => VInf(_verb);

  @override
  String getDebugLabel() => "VInf: ${_verb.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class VInfP implements SyntaxNode<VInfP> {
  final VInf _inf;
  final NP<dynamic>? _directObject;

  VInfP({
    required VInf inf,
    NP<dynamic>? directObject,
  })
      : _inf = inf,
        _directObject = directObject
  {
    if (directObject != null && directObject.caze != Case.acc) {
      throw ArgumentError.value(directObject.caze, "directObject.caze", "Direct object must be accusative");
    }
  }

  Tense get tense => _inf.tense;

  String translate() {
    String translation = _inf.translate();
    if (_directObject != null) {
      translation += " ${_directObject.translate(article: Article.definite)}";
    }
    return translation;
  }

  @override
  VInfP shallowClone() => VInfP(inf: _inf, directObject: _directObject);

  @override
  String getDebugLabel() => "VInfP";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [
    _inf,
    if (_directObject != null) LiteralDebugNode("NP_dirObj", [_directObject]),
  ];
}
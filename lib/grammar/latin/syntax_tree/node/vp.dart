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
import 'package:discipulus/grammar/latin/syntax_tree/node/np.dart';
import 'package:discipulus/grammar/latin/word_types.dart';

class V implements SyntaxNode<V> {
  // TODO add AdvP? or otherwise put in VP
  final Verb _verb;

  V(this._verb) {
    if (_verb.mood != Mood.ind) {
      throw ArgumentError.value(_verb.mood, "_verb.mood", "Mood must be indicative");
    }
  }

  Tense get tense => _verb.tense;
  Person get person => _verb.person;
  VerbKind get verbKind => _verb.verbKind;

  String translate() => person.person == 3 && !person.plural
      ? "${_verb.primaryTranslation}s"
      : _verb.primaryTranslation;

  @override
  V shallowClone() => V(_verb);

  @override
  String getDebugLabel() => "V: ${_verb.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class VP implements SyntaxNode<VP> {
  final V _v;
  final NP<dynamic>? _directObject;
  final NP<dynamic>? _indirectObject;
  // TODO PP*

  VP({required V verb, NP<dynamic>? directObject, NP<dynamic>? indirectObject}): _v = verb, _directObject = directObject, _indirectObject = indirectObject {
    if (directObject != null && directObject.caze != Case.acc) {
      throw ArgumentError.value(directObject.caze, "directObject.caze", "Direct Object must be accusative");
    }
    if (indirectObject != null && indirectObject.caze != Case.dat) {
      throw ArgumentError.value(indirectObject.caze, "indirectObject.caze", "Indirect Object must be dative");
    }
  }

  Tense get tense => _v.tense;
  Person get person => _v.person;

  String translate() {
    String translation = _v.translate();
    if (_directObject != null) {
      translation += " ${_directObject.translate(article: Article.definite)}";
    }
    if (_indirectObject != null) {
      translation += " ${_indirectObject.translate(article: Article.definite)}";
    }
    return translation;
  }

  @override
  VP shallowClone() => VP(verb: _v, directObject: _directObject, indirectObject: _indirectObject);

  @override
  String getDebugLabel() => "VP -> ${translate()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [
    _v,
    if (_directObject != null) LiteralDebugNode("NP_dirObj", [_directObject]),
    if (_indirectObject != null) LiteralDebugNode("NP_indObj", [_indirectObject]),
  ];
}
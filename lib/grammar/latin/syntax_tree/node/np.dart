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

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/word_types.dart';

enum Article {
  indefinite("a"),
  definite("the")
  ;
  final String translation;

  const Article(this.translation);

  String applyTo(String noun) => "$translation $noun";
}

abstract interface class NP<S extends NP<S>> implements SyntaxNode<S> {
  Case get caze;
  bool get plural;
  Gender get gender;

  bool canBeModifiedBy(AdjP<dynamic> adj);
  String translate({required Article? article});
}

abstract interface class AdjP<S extends AdjP<S>> implements SyntaxNode<S> {
  Case get caze;
  bool get plural;
  Gender get gender;
  ComparisonType get comparisonType;

  String translate({required NP<dynamic> target});
}

class NP$s implements NP<NP$s> {
  final Noun _noun;

  NP$s(this._noun);

  @override
  Case get caze => _noun.caze;

  @override
  Gender get gender => _noun.gender;

  @override
  bool get plural => _noun.plural;

  @override
  bool canBeModifiedBy(AdjP<dynamic> adj) {
    return adj.caze == caze &&
        adj.plural == plural &&
        adj.gender == gender;
  }

  @override
  String translate({required Article? article}) {
    if (_noun.isProper) article = null;
    return article?.applyTo(_noun.primaryTranslation) ?? _noun.primaryTranslation;
  }

  @override
  NP$s shallowClone() => NP$s(_noun);

  @override
  String getDebugLabel() => "NP_s: ${_noun.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class AdjP$s implements AdjP<AdjP$s> {
  final Adjective _adjective;

  AdjP$s(this._adjective);

  @override
  Case get caze => _adjective.caze;

  @override
  bool get plural => _adjective.plural;

  @override
  Gender get gender => _adjective.gender;

  @override
  ComparisonType get comparisonType => _adjective.comparisonType;

  @override
  String translate({required NP<dynamic> target}) =>
      _adjective.primaryTranslation;

  @override
  AdjP$s shallowClone() => AdjP$s(_adjective);

  @override
  String getDebugLabel() => "AdjP_s: ${_adjective.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class NP$c implements NP<NP$c> {
  final NP<dynamic> _a;
  final NP<dynamic> _b;

  NP$c(this._a, this._b) {
    if (_a.caze != _b.caze) {
      throw ArgumentError("Cases do not match: ${_a.caze} != ${_b.caze}");
    }
  }

  static bool isValidPair(NP<dynamic> a, NP<dynamic> b) => a.caze == b.caze;

  @override
  Case get caze => _a.caze;

  @override
  bool get plural => true;

  @override
  Gender get gender => (_a.gender == _b.gender) ? _a.gender : Gender.c;

  @override
  bool canBeModifiedBy(AdjP<dynamic> adj) => false;

  @override
  String translate({required Article? article}) =>
      "${_a.translate(article: article)} and ${_b.translate(article: article)}";

  @override
  NP$c shallowClone() => NP$c(_a, _b);

  @override
  String getDebugLabel() => "NP_c -> ${translate(article: null)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_a, LiteralDebugNode("et"), _b];
}

class NP$m implements NP<NP$m> {
  final NP<dynamic> _noun;
  final List<AdjP<dynamic>> _adjectives;

  NP$m(this._noun, this._adjectives) {
    for (final adj in _adjectives) {
      if (_noun.caze != adj.caze) {
        throw ArgumentError("Cases do not match: ${_noun.caze} != ${adj.caze}");
      }
      if (_noun.plural != adj.plural) {
        throw ArgumentError("Number doesn't match: ${_noun.plural ? 'plural' : 'singular'} != ${adj.plural ? 'plural' : 'singular'}");
      }
      if (!_noun.gender.equals(adj.gender)) {
        throw ArgumentError("Gender doesn't match: ${_noun.gender} != ${adj.gender}");
      }
    }
  }

  static bool isValidPair(NP<dynamic> noun, AdjP<dynamic> adj) =>
      noun.canBeModifiedBy(adj);

  @override
  Case get caze => _noun.caze;

  @override
  bool get plural => _noun.plural;

  @override
  Gender get gender => _noun.gender;

  @override
  bool canBeModifiedBy(AdjP<dynamic> adj) => _noun.canBeModifiedBy(adj);

  @override
  String translate({required Article? article}) {
    String base = [
      ..._adjectives.map((a) => a.translate(target: _noun)),
      _noun.translate(article: null)
    ].join(" ");
    return article?.applyTo(base) ?? base;
  }

  @override
  NP$m shallowClone() => NP$m(_noun, _adjectives.shallowCopy());

  NP$m cloneWithModifier(AdjP<dynamic> adj) => NP$m(_noun, [..._adjectives, adj]);

  @override
  String getDebugLabel() => "NP_m -> ${translate(article: Article.definite)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_noun, ..._adjectives];
}
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
import 'package:discipulus/grammar/english/micro_translation.dart';
import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/word_types.dart';

import 'rel.dart';
import 's.dart' as s;
import 'sbar.dart';
import 'vp.dart';

enum Article {
  indefinite("a", null),
  definite("the", "the")
  ;
  final String translation;
  final String? pluralTranslation;

  const Article(this.translation, this.pluralTranslation);

  String applyTo(String noun, bool plural) => plural
      ? (pluralTranslation == null ? noun : "$pluralTranslation $noun")
      : "$translation $noun";
}

abstract interface class LP<S extends LP<S>> implements SyntaxNode<S> {
  Case get caze;
  bool get plural;
  Gender get gender;

  String translateLP({List<s.S>? parents});
}

abstract interface class NP<S extends NP<S>> implements LP<S> {
  @override
  Case get caze;
  @override
  bool get plural;
  @override
  Gender get gender;

  bool canBeModifiedBy(AdjP<dynamic> adj);
  String translate({required Article? article, List<s.S>? parents});
}

abstract interface class AdjP<S extends AdjP<S>> implements LP<S> {
  @override
  Case get caze;
  @override
  bool get plural;
  @override
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
        adj.gender.equals(gender);
  }

  @override
  String translate({required Article? article, List<s.S>? parents}) {
    if (_noun.isProper) article = null;
    return article?.applyTo(_noun.primaryTranslation, plural) ?? _noun.primaryTranslation;
  }

  @override
  String translateLP({List<s.S>? parents}) =>
      translate(article: Article.indefinite, parents: parents);

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
  String translateLP({List<s.S>? parents}) => _adjective.primaryTranslation;

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

  static bool isValidTriple(NP<dynamic> a, Et _, NP<dynamic> b) => isValidPair(a, b);

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
  String translate({required Article? article, List<s.S>? parents}) =>
      "${_a.translate(article: article, parents: parents)} and ${_b.translate(article: article, parents: parents)}";

  @override
  String translateLP({List<s.S>? parents}) =>
      translate(article: Article.indefinite, parents: parents);

  @override
  NP$c shallowClone() => NP$c(_a, _b);

  @override
  String getDebugLabel() => "NP_c -> ${translate(article: Article.definite)}";

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
  String translate({required Article? article, List<s.S>? parents}) {
    String base = [
      ..._adjectives.reversed.map((a) => a.translate(target: _noun)),
      _noun.translate(article: null, parents: parents)
    ].join(" ");
    return article?.applyTo(base, plural) ?? base;
  }

  @override
  String translateLP({List<s.S>? parents}) =>
      translate(article: Article.indefinite, parents: parents);

  @override
  NP$m shallowClone() => NP$m(_noun, _adjectives.shallowCopy());

  NP$m cloneWithModifier(AdjP<dynamic> adj) => NP$m(_noun, [..._adjectives, adj]);

  @override
  String getDebugLabel() => "NP_m -> ${translate(article: Article.definite)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_noun, ..._adjectives];
}

class NP$r implements NP<NP$r> {
  final NP<dynamic> _noun;
  final RelClause _relClause;

  NP$r(this._noun, this._relClause) {
    if (_noun.caze != _relClause.caze) {
      throw ArgumentError("Cases do not match: ${_noun.caze} != ${_relClause.caze}");
    }
    if (_noun.plural != _relClause.plural) {
      throw ArgumentError("Number doesn't match: ${_noun.plural ? 'plural' : 'singular'} != ${_relClause.plural ? 'plural' : 'singular'}");
    }
    if (!_noun.gender.equals(_relClause.gender)) {
      throw ArgumentError("Gender doesn't match: ${_noun.gender} != ${_relClause.gender}");
    }
  }

  static bool isValidPair(NP<dynamic> noun, RelClause relClause) =>
      noun.caze == relClause.caze &&
      noun.plural == relClause.plural &&
      noun.gender.equals(relClause.gender);

  @override
  Case get caze => _noun.caze;

  @override
  bool get plural => _noun.plural;

  @override
  Gender get gender => _noun.gender;

  @override
  bool canBeModifiedBy(AdjP<dynamic> adj) => false;

  @override
  String translate({required Article? article, List<s.S>? parents}) =>
      "${_noun.translate(article: article, parents: parents)}, ${_relClause.translate()},";

  @override
  String translateLP({List<s.S>? parents}) =>
      translate(article: Article.indefinite, parents: parents);

  @override
  NP$r shallowClone() => NP$r(_noun, _relClause);

  @override
  String getDebugLabel() => "NP_r -> ${translate(article: Article.definite)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_noun, _relClause];
}

class NP$implicitSubject implements NP<NP$implicitSubject> {
  final Person _person;

  const NP$implicitSubject(this._person);

  factory NP$implicitSubject.fromVerb(VP<dynamic> vp) {
    return NP$implicitSubject(vp.person);
  }

  @override
  bool canBeModifiedBy(AdjP<dynamic> adj) => false;

  @override
  Case get caze => Case.nom;

  @override
  bool get plural => _person.plural;

  @override
  Gender get gender => Gender.x;

  @override
  NP$implicitSubject shallowClone() => NP$implicitSubject(_person);

  @override
  String getDebugLabel() => "NP_implicitSubject: $_person -> ${translate(article: null)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];

  @override
  String translate({required Article? article, List<s.S>? parents}) {
    Gender? parentGender = parents?.sublist(1)
        .where((s) => s.subject is! NP$implicitSubject && s.subject.plural == plural)
        .map((s) => s.subject.gender)
        .firstOrNull;

    final $gender = parentGender == null
        ? gender
        : gender.makeMoreSpecific(parentGender) ?? gender;

    return generatePronoun(_person, $gender);
  }

  @override
  String translateLP({List<s.S>? parents}) => throw UnimplementedError("translateLP() not implemented for NP\$implicitSubject");
}
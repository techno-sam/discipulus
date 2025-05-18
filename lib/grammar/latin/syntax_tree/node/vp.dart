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

import 'package:discipulus/grammar/english/micro_translation.dart' show conjugateToBe;
import 'package:discipulus/grammar/latin/grammar_types.dart';
import 'package:discipulus/grammar/latin/syntax_tree/base.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/np.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/pp.dart';
import 'package:discipulus/grammar/latin/syntax_tree/node/sbar.dart';
import 'package:discipulus/grammar/latin/word_types.dart';

import 's.dart' as s;

typedef AdverbConsumer = void Function(String);

abstract interface class V<S extends V<S>> implements SyntaxNode<S> {
  Tense get tense;
  Person get person;
  VerbKind get verbKind;

  bool get isLinkingVerb;

  String translate({bool suppress3S = false, AdverbConsumer? adverbConsumer});
}

abstract interface class AdvP<S extends AdvP<S>> implements SyntaxNode<S> {
  ComparisonType get comparisonType;

  String translate({required V<dynamic> target});
  bool isNot({required V<dynamic> target});
}

class V$s implements V<V$s> {
  final Verb _verb;

  V$s(this._verb) {
    if (_verb.mood != Mood.ind) {
      throw ArgumentError.value(_verb.mood, "_verb.mood", "Mood must be indicative");
    }
  }

  @override
  Tense get tense => _verb.tense;
  @override
  Person get person => _verb.person;
  @override
  VerbKind get verbKind => _verb.verbKind;
  @override
  bool get isLinkingVerb => _verb.isToBe; // todo expand to other linking verbs

  @override
  String translate({bool suppress3S = false, AdverbConsumer? adverbConsumer}) {
    if (_verb.isToBe) {
      return conjugateToBe(person);
    }
    return person.person == 3
      && !person.plural
      && !suppress3S
      ? _verb.primary3SingTranslation
      : _verb.primaryTranslation;
  }

  @override
  V$s shallowClone() => V$s(_verb);

  @override
  String getDebugLabel() => "V_s: ${_verb.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class AdvP$s implements AdvP<AdvP$s> {
  final Adverb _adverb;

  const AdvP$s(this._adverb);

  @override
  ComparisonType get comparisonType => _adverb.comparisonType;

  @override
  String translate({required V<dynamic> target}) =>
      _adverb.primaryTranslation;

  @override
  bool isNot({required V<dynamic> target}) => _adverb.word == "non";

  @override
  AdvP$s shallowClone() => AdvP$s(_adverb);

  @override
  String getDebugLabel() => "AdvP_s: ${_adverb.toColoredString()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [];
}

class V$m implements V<V$m> {
  final V<dynamic> _verb;
  final List<AdvP<dynamic>> _adverbs;

  const V$m(this._verb, this._adverbs);

  @override
  Tense get tense => _verb.tense;
  @override
  Person get person => _verb.person;
  @override
  VerbKind get verbKind => _verb.verbKind;
  @override
  bool get isLinkingVerb => _verb.isLinkingVerb;

  @override
  String translate({bool suppress3S = false, AdverbConsumer? adverbConsumer}) {
    bool negate = false;
    final List<String> translations = [];
    for (final adv in _adverbs) {
      if (adv.isNot(target: _verb)) {
        negate = !negate;
      } else {
        translations.add(adv.translate(target: _verb));
      }
    }

    final bool is3S = person.person == 3 && !person.plural && !suppress3S;
    final String verbTranslation;
    if (negate) {
      if (_verb.isLinkingVerb) {
        verbTranslation = "${_verb.translate()} not";
      } else if (is3S){
        verbTranslation = "does not ${_verb.translate(suppress3S: true)}";
      } else {
        verbTranslation = "do not ${_verb.translate(suppress3S: true)}";
      }
    } else {
      verbTranslation = _verb.translate(suppress3S: suppress3S);
    }

    String adverbPart = "";
    if (translations.isNotEmpty) {
      for (int i = 0; i < translations.length; i++) {
        if (i == 0) {
          adverbPart += translations[i];
        } else {
          adverbPart += " and ${translations[i]}";
        }
      }
    }

    if (adverbConsumer != null) {
      adverbConsumer(adverbPart);
      return verbTranslation;
    } else if (adverbPart.isNotEmpty) {
      return "$verbTranslation $adverbPart";
    } else {
      return verbTranslation;
    }
  }

  @override
  V$m shallowClone() => V$m(_verb, _adverbs);

  V$m cloneWithModifier(AdvP<dynamic> modifier) {
    return V$m(_verb, [..._adverbs, modifier]);
  }

  @override
  String getDebugLabel() => "V_m -> ${translate()}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [_verb, ..._adverbs];
}

abstract interface class VP<S extends VP<S>> implements SyntaxNode<S> {
  Tense get tense;
  Person get person;

  String translate(List<s.S>? parents);
}

class VP$s implements VP<VP$s> {
  final V<dynamic> _v;
  final NP<dynamic>? _directObject;
  final NP<dynamic>? _indirectObject;
  final List<PP> _prepositionalPhrases;
  final Sbar? _sbar;

  VP$s({
    required V<dynamic> verb,
    NP<dynamic>? directObject,
    NP<dynamic>? indirectObject,
    required List<PP> prepositionalPhrases,
    Sbar? sbar
  })
      : _v = verb,
        _directObject = directObject,
        _indirectObject = indirectObject,
        _prepositionalPhrases = prepositionalPhrases,
        _sbar = sbar
  {
    assert(!(_v.isLinkingVerb), "VP\$s cannot be a linking verb");

    if (directObject != null && directObject.caze != Case.acc) {
      throw ArgumentError.value(directObject.caze, "directObject.caze", "Direct Object must be accusative");
    }
    if (indirectObject != null && indirectObject.caze != Case.dat) {
      throw ArgumentError.value(indirectObject.caze, "indirectObject.caze", "Indirect Object must be dative");
    }
  }

  @override
  Tense get tense => _v.tense;
  @override
  Person get person => _v.person;

  @override
  String translate(List<s.S>? parents) {
    String adverbPart = "";
    void adverbConsumer(String advP) {
      adverbPart = advP;
    }

    String translation = _v.translate(adverbConsumer: adverbConsumer);
    if (_directObject != null) {
      translation += " ${_directObject.translate(article: Article.definite)}";
    }
    if (_indirectObject != null) {
      translation += " to ${_indirectObject.translate(article: Article.definite)}";
    }
    if (adverbPart.isNotEmpty) {
      translation += " $adverbPart";
    }
    for (final pp in _prepositionalPhrases) {
      translation += " ${pp.translate(article: Article.definite)}";
    }
    if (_sbar != null) {
      translation += ", ${_sbar.translate(parents)}";
    }
    return translation;
  }

  @override
  VP$s shallowClone() => VP$s(
      verb: _v,
      directObject: _directObject,
      indirectObject: _indirectObject,
      prepositionalPhrases: _prepositionalPhrases
  );

  @override
  String getDebugLabel() => "VP_s -> ${translate(null)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [
    _v,
    if (_directObject != null) LiteralDebugNode("NP_dirObj", [_directObject]),
    if (_indirectObject != null) LiteralDebugNode("NP_indObj", [_indirectObject]),
    ..._prepositionalPhrases,
    if (_sbar != null) _sbar
  ];
}

class VP$l implements VP<VP$l> {
  final V<dynamic> _v;
  final LP<dynamic>? _directObject;
  final List<PP> _prepositionalPhrases;
  final Sbar? _sbar;

  VP$l({
    required V<dynamic> verb,
    LP<dynamic>? directObject,
    required List<PP> prepositionalPhrases,
    Sbar? sbar
  })
      : _v = verb,
        _directObject = directObject,
        _prepositionalPhrases = prepositionalPhrases,
        _sbar = sbar
  {
    assert(_v.isLinkingVerb, "VP\$l must be a linking verb");

    if (directObject != null) {
      if (directObject.caze != Case.nom) {
        throw ArgumentError.value(directObject.caze, "directObject.caze",
            "Direct Object must be nominative");
      }
      if (directObject.plural != _v.person.plural) {
        throw ArgumentError.value(directObject.plural, "directObject.plural",
            "Direct Object must agree in number with the verb");
      }
    }
  }

  static bool isValidPair(V<dynamic> verb, LP<dynamic> directObject) {
    return verb.isLinkingVerb && directObject.caze == Case.nom && verb.person.plural == directObject.plural;
  }

  @override
  Tense get tense => _v.tense;
  @override
  Person get person => _v.person;

  LP<dynamic>? get directObject => _directObject;
  bool get hasPrepositionalPhrases => _prepositionalPhrases.isNotEmpty;

  @override
  String translate(List<s.S>? parents) {
    String translation = _v.translate();

    if (_directObject != null) {
      translation += " ${_directObject.translateLP(parents: parents)}";
    }

    for (final pp in _prepositionalPhrases) {
      translation += " ${pp.translate(article: Article.definite)}";
    }
    if (_sbar != null) {
      translation += ", ${_sbar.translate(parents)}";
    }
    return translation;
  }

  VP$l withoutDirectObject() => VP$l(
    verb: _v,
    prepositionalPhrases: _prepositionalPhrases
  );

  @override
  VP$l shallowClone() => VP$l(
      verb: _v,
      directObject: _directObject,
      prepositionalPhrases: _prepositionalPhrases
  );

  @override
  String getDebugLabel() => "VP_l -> ${translate(null)}";

  @override
  Iterable<TreeDebugNode> getDebugChildren() => [
    _v,
    if (_directObject != null) LiteralDebugNode("NP_dirObj", [_directObject]),
    ..._prepositionalPhrases,
    if (_sbar != null) _sbar
  ];
}
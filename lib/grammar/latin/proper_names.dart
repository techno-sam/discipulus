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

/*
Masculine |   Feminine
======================
r/us      |   a
i         |   ae
o         |   ae
um        |   am
o         |   a
i         |   ae
orum      |   arum
is        |   is
os        |   as
is        |   is
 */

import 'package:discipulus/datatypes.dart';

import 'noun.dart';

const List<String> _masc = ["us", "i", "o", "um", "o", "i", "orum", "is", "os", "is"];
const List<String> _fem = ["a", "ae", "ae", "am", "a", "ae", "arum", "is", "as", "is"];
const Map<Gender, List<String>> _endingSets = {
  Gender.m: _masc,
  Gender.f: _fem
};


class ProperName {
  final Map<String, Noun> _stringForms;
  final Map<Pair<Case, bool>, Noun> _forms;
  final Map<Pair<Case, bool>, String> _reverseForms;

  const ProperName._(
      Map<String, Noun> stringForms,
      Map<Pair<Case, bool>, Noun> forms,
      Map<Pair<Case, bool>, String> reverseForms
      ): _stringForms = stringForms, _forms = forms, _reverseForms = reverseForms;

  factory ProperName(String baseName) {
    Gender? gender;
    List<String>? endings;
    String? baserName;
    for (final MapEntry<Gender, List<String>> entry in _endingSets.entries) {
      final endingSet = entry.value;
      if (baseName.endsWith(endingSet[0])) {
        gender = entry.key;
        endings = endingSet;
        baserName = baseName.substring(0, baseName.length - endingSet[0].length);
        break;
      }
    }
    if (gender == null || endings == null || baserName == null) {
      throw ArgumentError.value(baseName, "baseName", "Base name must end with one of ${_masc[0]} or ${_fem[0]}");
    }
    final Map<String, Noun> stringForms = {};
    final Map<Pair<Case, bool>, Noun> forms = {};
    final Map<Pair<Case, bool>, String> reverseForms = {};
    for (int i = 0; i < 5; i++) {
      Case caze = Case.values[i];
      for ((bool, int) plural in [(false, 0), (true, 1)]) {
        final endingIdx = plural.$2 * 5 + i;
        final name = baserName + endings[endingIdx];
        final Noun noun = Noun.allTheParts(
          caze: caze,
          plural: plural.$1,
          gender: gender,
          parts: Couple(baserName+endings[0], baserName+endings[1]), translations: [[baseName]]
        );
        stringForms[name] = noun;
        final key = Pair(caze, plural.$1);
        forms[key] = noun;
        reverseForms[key] = name;
      }
    }
    return ProperName._(stringForms, forms, reverseForms);
  }

  void prettyPrint() {
    /* pretty |---| box with unicode box symbols */
    final int width = _stringForms.keys.map((s) => s.length).max;
    print("┌${"─" * (width + 2)}┐");
    for (final caze in Case.allCases) {
      print("│ ${_reverseForms[caze]!.padRight(width)} │");
    }
    print("└${"─" * (width + 2)}┘");
  }
}

class ProperNameSet {
  final Map<String, ProperName> properNames = {};

  ProperNameSet._();

  factory ProperNameSet(Iterable<String> names) {
    ProperNameSet set = ProperNameSet._();
    for (final name in names) {
      if (name.isEmpty) continue;
      set.register(name);
    }
    return set;
  }

  void register(String name) {
    properNames[name] = ProperName(name);
  }

  Noun? parse(String word) {
    return properNames.values.map((pn) => pn._stringForms[word]).firstOrNull;
  }
}

final ProperNameSet properNames = ProperNameSet("Cornelius Cornelia Flavia".split(" "));
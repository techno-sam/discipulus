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

// https://mk270.github.io/whitakers-words/programme.html
enum Case {
  nom("Nominative"),
  gen("Genitive"),
  dat("Dative"),
  acc("Accusative"),
  abl("Ablative")
  ;

  final String description;
  const Case(this.description);

  static Case? decode(String str) {
    str = str.toLowerCase().trim();
    return Case.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}

enum Gender {
  x("All, none, unknown"),
  m("Masculine"),
  f("Feminine"),
  n("Neuter"),
  c("Common (masc and/or fem)")
  ;

  final String description;
  const Gender(this.description);

  static Gender? decode(String str) {
    str = str.toLowerCase().trim();
    return Gender.values
        .where((t) => t.name.toLowerCase() == str)
        .firstOrNull;
  }

  @override
  String toString() {
    return "$name($description)";
  }
}
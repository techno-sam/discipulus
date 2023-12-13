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

final Regexes re = Regexes();

class Regexes {
  // https://regex101.com/r/oeeOrH/latest
  RegExp l01verb = RegExp(r"^(?:01 )(?<split>[a-z.]+)(?:\s+V\s+\d\s+\d\s+)(?<tense>[a-zA-Z]+)(?:\s+)(?<voice>[a-zA-Z]+)(?:\s+)(?<mood>[a-zA-Z]+)(?:\s+)(?<person_num>\d)(?:\s+)(?<person_pl>S|P)$");
  // https://regex101.com/r/VnXEaF/latest
  RegExp l02verb = RegExp(r"^(?:02 )(?<parts>(?:[a-zA-Z]+(?:,\s)?){3,4})(?:\s+V\s+(?:\(\d[a-z]+\))?\s+(?<verb_type>X|TO_BE|TO_BEING|GEN|DAT|ABL|TRANS|INTRANS|IMPERS|DEP|SEMIDEP|PERFDEP)?\s+\[[A-Z]+\])");

  // https://regex101.com/r/any4DT/latest
  RegExp l01noun = RegExp(r"^(?:01 )(?<split>[a-z.]+)(?:\s+N\s+\d\s+\d\s+)(?<case>[a-zA-Z]+)(?:\s+)(?<person_pl>S|P)(?:\s+)(?<gender>X|M|F|N|C)$");
  // https://regex101.com/r/thfvI2/latest
  RegExp l02noun = RegExp(r"^(?:02 )(?<parts>(?:[a-zA-Z]+(?:,\s)?){2})(?:\s+N\s+\(\d[a-z]+\)\s+)(?<gender>X|M|F|N|C)(?:\s+\[[A-Z]+\])");

  // https://regex101.com/r/8Jc46N/latest
  RegExp l01adjective = RegExp(r"^(?:01 )(?<split>[a-z.]+)(?:\s+ADJ\s+\d\s+\d\s+)(?<case>[a-zA-Z]+)(?:\s+)(?<person_pl>S|P)(?:\s+)(?<gender>X|M|F|N|C)(?:\s+)(?<comparison_type>X|POS|COMP|SUPER)$");
  // https://regex101.com/r/jLbBXW/latest
  RegExp l02adjective = RegExp(r"^(?:02 )(?<parts>(?:[a-zA-Z\- ]*[a-zA-Z\-](?:,\s)){2,3}(?:[a-zA-Z\- ]*[a-zA-Z\-]))(?:\s+ADJ\s+\[[A-Z]+\])");

  // https://regex101.com/r/or0bc5/latest
  RegExp l01preposition = RegExp(r"^(?:01 )(?<word>[a-z]+)(?:\s+PREP\s+)(?<case>[a-zA-Z]+)$");
  // https://regex101.com/r/eiSGvF/latest
  RegExp l02preposition = RegExp(r"^(?:02 )(?<word>[a-zA-Z]+)(?:\s+PREP\s+)(?<case>[a-zA-Z]+)(?:\s+\[[A-Z]+\])");

  // https://regex101.com/r/yQm1yc/latest
  RegExp l01adverb = RegExp(r"^(?:01 )(?<word>[a-z]+)(?:\s+ADV\s+)(?<comparison_type>X|POS|COMP|SUPER)$");
  // https://regex101.com/r/JelAc4/latest
  RegExp l02adverb = RegExp(r"^(?:02 )(?<parts>[a-zA-Z]+(?:,\s[a-zA-Z]+)*)(?:\s+ADV\s+\[[A-Z]+\])");

  // https://regex101.com/r/nXhr6L/latest
  RegExp l01pronoun = RegExp(r"^(?:01 )(?<split>[a-z.]+)(?:\s+PRON\s+\d\s+\d\s+)(?<case>[a-zA-Z]+)(?:\s+)(?<person_pl>S|P)(?:\s+)(?<gender>X|M|F|N|C)$");
  // https://regex101.com/r/ePXrPo/latest
  RegExp l02pronoun = RegExp(r"^(?:02 )(?:\s+\[[A-Z]+\])");
}
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

import 'package:discipulus/datatypes.dart';
import 'package:discipulus/grammar/english/micro_translation.dart';
import 'package:discipulus/grammar/latin/lines.dart';
import 'package:discipulus/grammar/latin/noun.dart';
import 'package:discipulus/grammar/latin/proper_names.dart';
import 'package:discipulus/grammar/latin/sentence.dart';
import 'package:discipulus/grammar/latin/verb.dart';
import 'package:discipulus/utils/colors.dart';

const String puellaWords = """01 puell.a              N      1 1 NOM S F                 
01 puell.a              N      1 1 VOC S F                 
01 puell.a              N      1 1 ABL S F                 
02 puella, puellae  N (1st) F   [XXXBO]  
03 girl, (female) child/daughter; maiden; young woman/wife; sweetheart; slavegirl;""";

const String vocatWords = """01 voc.at               V      1 1 PRES ACTIVE  IND 3 S    
02 voco, vocare, vocavi, vocatus  V (1st)   [XXXAX]  
03 call, summon; name; call upon;""";

const String pueriWords = """01 puer.i               N      2 3 GEN S M                 
01 puer.i               N      2 3 LOC S M                 
01 puer.i               N      2 3 NOM P M                 
01 puer.i               N      2 3 VOC P M                 
02 puer, pueri  N (2nd) M   [XXXAX]  
03 boy, lad, young man; servant; (male) child; [a puere => from boyhood];""";

void main() {
  print("run/trot/gallop, hurry/hasten/speed".split(RegExp(r"[,/]")));

  print("all cases:");
  print(Case.allCases);

  print("Forms of 'Cornelia'");
  properNames.properNames["Cornelia"]!.prettyPrint();

  print("\nForms of 'Marcus'");
  properNames.properNames["Marcus"]!.prettyPrint();

  print("puella:");
  final puellaLines = parseToLines(puellaWords);
  print(puellaLines);
  print("possible forms:");
  for (final pos in parseToPOS(puellaLines)) {
    print("\t$pos");
  }

  print("\n\nvocat:");
  final vocatLines = parseToLines(vocatWords);
  print(vocatLines);
  print("possible forms:");
  var vocatForms = parseToPOS(vocatLines);
  for (final pos in vocatForms) {
    print("\t$pos");
  }
  final Verb? vocatVerb = vocatForms.where((pos) => pos is Verb).map((pos) => pos as Verb).firstOrNull;
  if (vocatVerb != null) {
    printTranslationTable(vocatVerb);
  }

  print("\n\npueri:");
  final pueriLines = parseToLines(pueriWords);
  print(pueriLines);
  print("possible forms:");
  for (final pos in parseToPOS(pueriLines)) {
    print("\t$pos");
  }

  const testSentences = [
    "puella ambulat",
    "ambulo",
    "puer vocat",
    "regimus",
    "Cornelia ambulat",
    "Marcus audit fragorem", // originally Marcus audit magnum fragorem
    "Marcus audit magnum fragorem",
    "Marcus audit fragorem magnissimum",
    "Marcum adjuvat Cornelia", // Object Verb Subject
    "Cornelia ambulat Marcum", // 'ambulat' is intransitive, so this should fail to translate
    "Flavia vocat puellam Romanam",
    "Flavia est puella Romana",
    "Cornelia et Flavia vocant",
    "Cornelia et Flavia sunt puellae Romanae",
    "Marcus et puellae ambulant",
    "Cornelia et Flavia sunt amicae",
    "Cornelia sub arbore sedet cum Flavia",
    "Cornelia et raedae sunt in pictura",
    "in pictura est villa cum raeda",
    "Marcus et ego celeriter ambulant ad hortum cum Cornelia",
    "Cornelia iam vocat",
    "Cornelia ambulat cito",
    "Cornelia ambulat citius",
    "Cornelia ambulat citissime",
    "Cornelia iam sub arbore sedet et legit",
    "Sextus et Marcus non laborant et sunt raedae",
    "Sextus et Marcus non laborant quod sunt pueri Romani et non volunt laborare",
    "pueri glires edunt in foro quod famem habent",
    "Sextus et Flavia glires non edunt quod non sunt cives Romanae"
  ];
  for (Pair<int, String> pair in testSentences.enumerate) {
    final String testSentence = pair.second;
    print("\n\nAll possibilities for ${Style.BRIGHT}$testSentence${Style.RESET_ALL}${Fore.LIGHTBLACK_EX}${Style.DIM}");
    final SentenceBundle bundle;
    final bool skipUntranslatable = pair.first < testSentences.length - 1;
    try {
      bundle = SentenceBundle.fromSentence(testSentence, debugMode: true, print: skipUntranslatable ? (s) {} : print);
    } catch (e, s) {
      print(Style.RESET_ALL+Fore.RED);
      print(e);
      print(s);
      continue;
    }
    bundle.printAllPossibilities(skipUntranslatable: skipUntranslatable);
  }
}
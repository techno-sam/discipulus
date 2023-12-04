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

import 'package:discipulus/grammar/latin/lines.dart';

const String puellaWords = """01 puell.a              N      1 1 NOM S F                 
01 puell.a              N      1 1 VOC S F                 
01 puell.a              N      1 1 ABL S F                 
02 puella, puellae  N (1st) F   [XXXBO]  
03 girl, (female) child/daughter; maiden; young woman/wife; sweetheart; slavegirl;""";

const String vocatWords = """01 voc.at               V      1 1 PRES ACTIVE  IND 3 S    
02 voco, vocare, vocavi, vocatus  V (1st)   [XXXAX]  
03 call, summon; name; call upon;""";

void main() {
  print("run/trot/gallop, hurry/hasten/speed".split(RegExp(r"[,/]")));

  print("puella:");
  print(parseToLines(puellaWords));

  print("\nvocat:");
  print(parseToLines(vocatWords));
}
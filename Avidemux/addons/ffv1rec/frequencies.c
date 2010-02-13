/* 
 * This code is taken from xawdecode and adapted a bit...
 * purpose: make ffv1rec able to read xawdecode's channel tables.
 * The code is neither fast nor elegant, but since it runs only once on startup
 * I didn't care
 */


/*****************************************************************************
 * frequencies.c: frequencies TV table
 *****************************************************************************
 * $Id: frequencies.c 1039 2005-05-17 19:01:18Z mean $
 *****************************************************************************
 * Copyright (C) 2003 Keuleu
 * Thu 06 Nov 2003 10:50:41 AM EET - Lucian Langa <cooly@eweb.ro>
 *	Added SR1-SR8, SR11-SR18 channels for east-europe freq table
 * Wed 10 Dec 2003 04:00:49 PM EET - cooly
 *	Added secam-russia tab
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.
 *****************************************************************************/






/* COMPREHENSIVE LIST OF FORMAT BY COUNTRY
   (M) NTSC used in:
    Antigua, Aruba, Bahamas, Barbados, Belize, Bermuda, Bolivia, Burma,
    Canada, Chile, Colombia, Costa Rica, Cuba, Curacao, Dominican Republic,
    Ecuador, El Salvador, Guam Guatemala, Honduras, Jamaica, Japan,
    South Korea, Mexico, Montserrat, Myanmar, Nicaragua, Panama, Peru,
    Philippines, Puerto Rico, St Christopher and Nevis, Samoa, Suriname,
    Taiwan, Trinidad/Tobago, United States, Venezuela, Virgin Islands
   (B) PAL used in:
    Albania, Algeria, Australia, Austria, Bahrain, Bangladesh, Belgium,
    Bosnia-Herzegovinia, Brunei Darussalam, Cambodia, Cameroon, Croatia,
    Cyprus, Denmark, Egypt, Ethiopia, Equatorial Guinea, Finland, Germany,
    Ghana, Gibraltar, Greenland, Iceland, India, Indonesia, Israel, Italy,
    Jordan, Kenya, Kuwait, Liberia, Libya, Luxembourg, Malaysa, Maldives,
    Malta, Nepal, Netherlands, New Zeland, Nigeria, Norway, Oman, Pakistan,
    Papua New Guinea, Portugal, Qatar, Sao Tome and Principe, Saudi Arabia,
    Seychelles, Sierra Leone, Singapore, Slovenia, Somali, Spain,
    Sri Lanka, Sudan, Swaziland, Sweden, Switzeland, Syria, Thailand,
    Tunisia, Turkey, Uganda, United Arab Emirates, Yemen
   (N) PAL used in: (Combination N = 4.5MHz audio carrier, 3.58MHz burst)
    Argentina (Combination N), Paraguay, Uruguay
   (M) PAL (525/60, 3.57MHz burst) used in:
    Brazil
   (G) PAL used in:
    Albania, Algeria, Austria, Bahrain, Bosnia/Herzegovinia, Cambodia,
    Cameroon, Croatia, Cyprus, Denmark, Egypt, Ethiopia, Equatorial Guinea,
    Finland, Germany, Gibraltar, Greenland, Iceland, Israel, Italy, Jordan,
    Kenya, Kuwait, Liberia, Libya, Luxembourg, Malaysia, Monaco,
    Mozambique, Netherlands, New Zealand, Norway, Oman, Pakistan,
    Papa New Guinea, Portugal, Qatar, Romania, Sierra Leone, Singapore,
    Slovenia, Somalia, Spain, Sri Lanka, Sudan, Swaziland, Sweeden,
    Switzerland, Syria, Thailand, Tunisia, Turkey, United Arab Emirates,
    Yemen, Zambia, Zimbabwe
   (D) PAL used in:
    China, North Korea, Romania
   (H) PAL used in:
    Belgium
   (I) PAL used in:
    Angola, Botswana, Gambia, Guinea-Bissau, Hong Kong, Ireland, Lesotho,
    Malawi, Nambia, Nigeria, South Africa, Tanzania, United Kingdom,
    Zanzibar
   (B) SECAM used in:
    Djibouti, Greece, Iran, Iraq, Lebanon, Mali, Mauritania, Mauritus,
    Morocco
   (D) SECAM used in:
    Afghanistan, Armenia, Azerbaijan, Belarus, Bulgaria, Czech Republic,
    Estonia, Georgia, Hungary, Zazakhstan, Lithuania, Mongolia, Moldova,
    Poland, Russia, Slovak Republic, Ukraine, Vietnam
   (G) SECAM used in:
    Greecem Iran, Iraq, Mali, Mauritus, Morocco, Saudi Arabia
   (K) SECAM used in:
    Armenia, Azerbaijan, Bulgaria, Czech Republic, Estonia, Georgia,
    Hungary, Kazakhstan, Lithuania, Madagascar, Moldova, Poland, Russia,
    Slovak Republic, Ukraine, Vietnam
   (K1) SECAM used in:
    Benin, Burkina Faso, Burundi, Chad, Cape Verde, Central African
    Republic, Comoros, Congo, Gabon, Madagascar, Niger, Rwanda, Senegal,
    Togo, Zaire
   (L) SECAM used in:
    France
*/
struct freqlist
{
  char name[5];
  int freq[12];
};




#include <stdlib.h>
#include <stdio.h>
#include <string.h>
struct STRTAB
{
  int nr;
  char *str;
};

struct STRTAB chan_names[] = {
  {0, "ntsc-bcast"},
  {1, "ntsc-cable"},
  {2, "ntsc-bcast-jp"},
  {3, "ntsc-cable-jp"},
  {4, "secam-france"},
  {5, "secam-russia"},
  {6, "pal-europe"},
  {7, "pal-europe-east"},
  {8, "pal-italy"},
  {9, "pal-newzealand"},
  {10, "pal-australia"},
  {11, "pal-ireland"},
  {-1, NULL}
};


/* ------------------------------------------------------------------------- */
/* moved here from channels.h                                                */

/* NOTE : NTSC BROADCAST OVER 69 WERE RE-ALLOCATED CELLULAR, included anyway */

struct freqlist tvtuner[] = {
/* CH    US-TV US-CATV JP-TV JP-CATV SECAMF SECAMR EUROPE  EUR-E  ITALY    NZ     AU UHF_GHI */
  {"K02", {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"E2", {0, 0, 0, 0, 48250, 0, 48250, 0, 0, 0, 0, 0}},
  {"E3", {0, 0, 0, 0, 55250, 0, 55250, 0, 0, 0, 0, 0}},
  {"E4", {0, 0, 0, 0, 62250, 0, 62250, 0, 0, 0, 0, 0}},

  {"S01", {0, 0, 0, 0, 0, 0, 69250, 0, 0, 0, 0, 0}},
  {"S02", {0, 0, 0, 0, 0, 0, 76250, 0, 0, 0, 0, 0}},
  {"S03", {0, 0, 0, 0, 0, 0, 83250, 0, 0, 0, 0, 0}},

  {"R1", {0, 0, 0, 0, 0, 49750, 0, 49750, 0, 0, 0, 0}},
  {"R2", {0, 0, 0, 0, 0, 59250, 0, 59250, 0, 0, 0, 0}},
  {"R3", {0, 0, 0, 0, 0, 77250, 0, 77250, 0, 0, 0, 0}},
  {"R4", {0, 0, 0, 0, 0, 84250, 0, 84250, 0, 0, 0, 0}},
  {"R5", {0, 0, 0, 0, 0, 93250, 0, 93250, 0, 0, 0, 0}},

  {"SE1", {0, 0, 0, 0, 105250, 0, 105250, 105250, 0, 0, 0, 0}},
  {"SE2", {0, 0, 0, 0, 112250, 0, 112250, 112250, 0, 0, 0, 0}},
  {"SE3", {0, 0, 0, 0, 119250, 0, 119250, 119250, 0, 0, 0, 0}},
  {"SE4", {0, 0, 0, 0, 126250, 0, 126250, 126250, 0, 0, 0, 0}},
  {"SE5", {0, 0, 0, 0, 133250, 0, 133250, 133250, 0, 0, 0, 0}},
  {"SE6", {0, 0, 0, 0, 140250, 0, 140250, 140250, 0, 0, 0, 0}},
  {"SE7", {0, 0, 0, 0, 147250, 0, 147250, 147250, 0, 0, 0, 0}},
  {"SE8", {0, 0, 0, 0, 154250, 0, 154250, 154250, 0, 0, 0, 0}},
  {"SE9", {0, 0, 0, 0, 161250, 0, 161250, 161250, 0, 0, 0, 0}},
  {"SE10", {0, 0, 0, 0, 168250, 0, 168250, 168250, 0, 0, 0, 0}},

  {"E5", {0, 0, 0, 0, 175250, 0, 175250, 0, 0, 0, 0, 0}},
  {"E6", {0, 0, 0, 0, 182250, 0, 182250, 0, 0, 0, 0, 0}},
  {"E7", {0, 0, 0, 0, 189250, 0, 189250, 0, 0, 0, 0, 0}},
  {"E8", {0, 0, 0, 0, 196250, 0, 196250, 0, 0, 0, 0, 0}},
  {"E9", {0, 0, 0, 0, 203250, 0, 203250, 0, 0, 0, 0, 0}},
  {"E10", {0, 0, 0, 0, 210250, 0, 210250, 0, 0, 0, 0, 0}},
  {"E11", {0, 0, 0, 0, 217250, 0, 217250, 0, 0, 0, 0, 0}},
  {"E12", {0, 0, 0, 0, 224250, 0, 224250, 0, 0, 0, 0, 0}},

  {"R6", {0, 0, 0, 0, 0, 175250, 0, 175250, 0, 0, 0, 0}},
  {"R7", {0, 0, 0, 0, 0, 183250, 0, 183250, 0, 0, 0, 0}},
  {"R8", {0, 0, 0, 0, 0, 191250, 0, 191250, 0, 0, 0, 0}},
  {"R9", {0, 0, 0, 0, 0, 199250, 0, 199250, 0, 0, 0, 0}},
  {"R10", {0, 0, 0, 0, 0, 207250, 0, 207250, 0, 0, 0, 0}},
  {"R11", {0, 0, 0, 0, 0, 215250, 0, 215250, 0, 0, 0, 0}},
  {"R12", {0, 0, 0, 0, 0, 223250, 0, 223250, 0, 0, 0, 0}},

  {"SE11", {0, 0, 0, 0, 231250, 0, 231250, 231250, 0, 0, 0, 0}},
  {"SE12", {0, 0, 0, 0, 238250, 0, 238250, 238250, 0, 0, 0, 0}},
  {"SE13", {0, 0, 0, 0, 245250, 0, 245250, 245250, 0, 0, 0, 0}},
  {"SE14", {0, 0, 0, 0, 252250, 0, 252250, 252250, 0, 0, 0, 0}},
  {"SE15", {0, 0, 0, 0, 259250, 0, 259250, 259250, 0, 0, 0, 0}},
  {"SE16", {0, 0, 0, 0, 266250, 0, 266250, 266250, 0, 0, 0, 0}},
  {"SE17", {0, 0, 0, 0, 273250, 0, 273250, 273250, 0, 0, 0, 0}},
  {"SE18", {0, 0, 0, 0, 280250, 0, 280250, 280250, 0, 0, 0, 0}},
  {"SE19", {0, 0, 0, 0, 287250, 0, 287250, 287250, 0, 0, 0, 0}},
  {"SE20", {0, 0, 0, 0, 294250, 0, 294250, 294250, 0, 0, 0, 0}},

  {"SR1", {0, 0, 0, 0, 0, 111250, 0, 111250, 0, 0, 0, 0}},
  {"SR2", {0, 0, 0, 0, 0, 119250, 0, 119250, 0, 0, 0, 0}},
  {"SR3", {0, 0, 0, 0, 0, 127250, 0, 127250, 0, 0, 0, 0}},
  {"SR4", {0, 0, 0, 0, 0, 135250, 0, 135250, 0, 0, 0, 0}},
  {"SR5", {0, 0, 0, 0, 0, 143250, 0, 143250, 0, 0, 0, 0}},
  {"SR6", {0, 0, 0, 0, 0, 151250, 0, 151250, 0, 0, 0, 0}},
  {"SR7", {0, 0, 0, 0, 0, 159250, 0, 159250, 0, 0, 0, 0}},
  {"SR8", {0, 0, 0, 0, 0, 167250, 0, 167250, 0, 0, 0, 0}},
  
  {"SR11", {0, 0, 0, 0, 0, 231250, 0, 231250, 0, 0, 0, 0}},
  {"SR12", {0, 0, 0, 0, 0, 239250, 0, 239250, 0, 0, 0, 0}},
  {"SR13", {0, 0, 0, 0, 0, 247250, 0, 247250, 0, 0, 0, 0}},
  {"SR14", {0, 0, 0, 0, 0, 255250, 0, 255250, 0, 0, 0, 0}},
  {"SR15", {0, 0, 0, 0, 0, 263250, 0, 263250, 0, 0, 0, 0}},
  {"SR16", {0, 0, 0, 0, 0, 271250, 0, 271250, 0, 0, 0, 0}},
  {"SR17", {0, 0, 0, 0, 0, 279250, 0, 279250, 0, 0, 0, 0}},
  {"SR18", {0, 0, 0, 0, 0, 287259, 0, 287250, 0, 0, 0, 0}},

  {"S21", {0, 0, 0, 0, 303250, 303250, 303250, 303250, 0, 0, 0, 0}},
  {"S22", {0, 0, 0, 0, 311250, 311250, 311250, 311250, 0, 0, 0, 0}},
  {"S23", {0, 0, 0, 0, 319250, 319250, 319250, 319250, 0, 0, 0, 0}},
  {"S24", {0, 0, 0, 0, 327250, 327250, 327250, 327250, 0, 0, 0, 0}},
  {"S25", {0, 0, 0, 0, 335250, 335250, 335250, 335250, 0, 0, 0, 0}},
  {"S26", {0, 0, 0, 0, 343250, 343250, 343250, 343250, 0, 0, 0, 0}},
  {"S27", {0, 0, 0, 0, 351250, 351250, 351250, 351250, 0, 0, 0, 0}},
  {"S28", {0, 0, 0, 0, 359250, 359250, 359250, 359250, 0, 0, 0, 0}},
  {"S29", {0, 0, 0, 0, 367250, 367250, 367250, 367250, 0, 0, 0, 0}},
  {"S30", {0, 0, 0, 0, 375250, 375250, 375250, 375250, 0, 0, 0, 0}},
  {"S31", {0, 0, 0, 0, 383250, 383250, 383250, 383250, 0, 0, 0, 0}},
  {"S32", {0, 0, 0, 0, 391250, 391250, 391250, 391250, 0, 0, 0, 0}},
  {"S33", {0, 0, 0, 0, 399250, 399250, 399250, 399250, 0, 0, 0, 0}},
  {"S34", {0, 0, 0, 0, 407250, 407250, 407250, 407250, 0, 0, 0, 0}},
  {"S35", {0, 0, 0, 0, 415250, 415250, 415250, 415250, 0, 0, 0, 0}},
  {"S36", {0, 0, 0, 0, 423250, 423250, 423250, 423250, 0, 0, 0, 0}},
  {"S37", {0, 0, 0, 0, 431250, 431250, 431250, 431250, 0, 0, 0, 0}},
  {"S38", {0, 0, 0, 0, 439250, 439250, 439250, 439250, 0, 0, 0, 0}},
  {"S39", {0, 0, 0, 0, 447250, 447250, 447250, 447250, 0, 0, 0, 0}},
  {"S40", {0, 0, 0, 0, 455250, 455250, 455250, 455250, 0, 0, 0, 0}},
  {"S41", {0, 0, 0, 0, 463250, 463250, 463250, 463250, 0, 0, 0, 0}},

  {"K01", {0, 0, 0, 0, 47750, 0, 0, 0, 0, 0, 0, 0}},
  {"K02", {0, 0, 0, 0, 55750, 0, 0, 0, 0, 0, 0, 0}},
  {"K03", {0, 0, 0, 0, 60500, 0, 0, 0, 0, 0, 0, 0}},
  {"K04", {0, 0, 0, 0, 63750, 0, 0, 0, 0, 0, 0, 0}},
  {"K05", {0, 0, 0, 0, 176000, 0, 0, 0, 0, 0, 0, 0}},
  {"K06", {0, 0, 0, 0, 184000, 0, 0, 0, 0, 0, 0, 0}},
  {"K07", {0, 0, 0, 0, 192000, 0, 0, 0, 0, 0, 0, 0}},
  {"K08", {0, 0, 0, 0, 200000, 0, 0, 0, 0, 0, 0, 0}},
  {"K09", {0, 0, 0, 0, 208000, 0, 0, 0, 0, 0, 0, 0}},
  {"K10", {0, 0, 0, 0, 216000, 0, 0, 0, 0, 0, 0, 0}},
  {"K B", {0, 0, 0, 0, 116750, 0, 0, 0, 0, 0, 0, 0}},
  {"K C", {0, 0, 0, 0, 128750, 0, 0, 0, 0, 0, 0, 0}},
  {"K D", {0, 0, 0, 0, 140750, 0, 0, 0, 0, 0, 0, 0}},
  {"K E", {0, 0, 0, 0, 159750, 0, 0, 0, 0, 0, 0, 0}},
  {"K F", {0, 0, 0, 0, 164750, 0, 0, 0, 0, 0, 0, 0}},
  {"K G", {0, 0, 0, 0, 176750, 0, 0, 0, 0, 0, 0, 0}},
  {"K H", {0, 0, 0, 0, 188750, 0, 0, 0, 0, 0, 0, 0}},
  {"K I", {0, 0, 0, 0, 200750, 0, 0, 0, 0, 0, 0, 0}},
  {"K J", {0, 0, 0, 0, 212750, 0, 0, 0, 0, 0, 0, 0}},
  {"K K", {0, 0, 0, 0, 224750, 0, 0, 0, 0, 0, 0, 0}},
  {"K L", {0, 0, 0, 0, 236750, 0, 0, 0, 0, 0, 0, 0}},
  {"K M", {0, 0, 0, 0, 248750, 0, 0, 0, 0, 0, 0, 0}},
  {"K N", {0, 0, 0, 0, 260750, 0, 0, 0, 0, 0, 0, 0}},
  {"K O", {0, 0, 0, 0, 272750, 0, 0, 0, 0, 0, 0, 0}},
  {"K P", {0, 0, 0, 0, 284750, 0, 0, 0, 0, 0, 0, 0}},
  {"K Q", {0, 0, 0, 0, 296750, 0, 0, 0, 0, 0, 0, 0}},
  {"H01", {0, 0, 0, 0, 303250, 0, 0, 0, 0, 0, 0, 0}},
  {"H02", {0, 0, 0, 0, 311250, 0, 0, 0, 0, 0, 0, 0}},
  {"H03", {0, 0, 0, 0, 319250, 0, 0, 0, 0, 0, 0, 0}},
  {"H04", {0, 0, 0, 0, 327250, 0, 0, 0, 0, 0, 0, 0}},
  {"H05", {0, 0, 0, 0, 335250, 0, 0, 0, 0, 0, 0, 0}},
  {"H06", {0, 0, 0, 0, 343250, 0, 0, 0, 0, 0, 0, 0}},
  {"H07", {0, 0, 0, 0, 351250, 0, 0, 0, 0, 0, 0, 0}},
  {"H08", {0, 0, 0, 0, 359250, 0, 0, 0, 0, 0, 0, 0}},
  {"H09", {0, 0, 0, 0, 367250, 0, 0, 0, 0, 0, 0, 0}},
  {"H10", {0, 0, 0, 0, 375250, 0, 0, 0, 0, 0, 0, 0}},
  {"H11", {0, 0, 0, 0, 383250, 0, 0, 0, 0, 0, 0, 0}},
  {"H12", {0, 0, 0, 0, 391250, 0, 0, 0, 0, 0, 0, 0}},
  {"H13", {0, 0, 0, 0, 399250, 0, 0, 0, 0, 0, 0, 0}},
  {"H14", {0, 0, 0, 0, 407250, 0, 0, 0, 0, 0, 0, 0}},
  {"H15", {0, 0, 0, 0, 415250, 0, 0, 0, 0, 0, 0, 0}},
  {"H16", {0, 0, 0, 0, 423250, 0, 0, 0, 0, 0, 0, 0}},
  {"H17", {0, 0, 0, 0, 431250, 0, 0, 0, 0, 0, 0, 0}},
  {"H18", {0, 0, 0, 0, 439250, 0, 0, 0, 0, 0, 0, 0}},
  {"H19", {0, 0, 0, 0, 447250, 0, 0, 0, 0, 0, 0, 0}},

  {"0", {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 46250, 45750}},
  {"1", {0, 73250, 91250, 0, 0, 0, 0, 0, 0, 45250, 57250, 53750}},
  {"2", {55250, 55250, 97250, 0, 0, 0, 0, 0, 53750, 55250, 64250, 61750}},
  {"3", {61250, 61250, 103250, 0, 0, 0, 0, 0, 62250, 62250, 86250, 175250}},
  {"4", {67250, 67250, 171250, 0, 0, 0, 0, 0, 82250, 175250, 95250, 183250}},
  {"5", {77250, 77250, 177250, 0, 0, 0, 0, 0, 175250, 182250, 102250, 191250}},
  {"5A", {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 138250, 0}},
  {"6", {83250, 83250, 183250, 0, 0, 0, 0, 0, 183750, 189250, 175250, 199250}},
  {"7", {175250, 175250, 189250, 0, 0, 0, 0, 0, 192250, 196250, 182250, 207250}},
  {"8", {181250, 181250, 193250, 0, 0, 0, 0, 0, 201250, 203250, 189250, 215250}},
  {"9", {187250, 187250, 199250, 0, 0, 0, 0, 0, 210250, 210250, 196250, 0}},
  {"10", {193250, 193250, 205250, 0, 0, 0, 0, 0, 210250, 217250, 209250, 0}},
  {"11", {199250, 199250, 211250, 0, 0, 0, 0, 0, 217250, 0, 216250, 0}},
  {"12", {205250, 205250, 217250, 0, 0, 0, 0, 0, 224250, 0, 0, 0}},

  {"13", {211250, 211250, 0, 109250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"14", {471250, 121250, 0, 115250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"15", {477250, 127250, 0, 121250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"16", {483250, 133250, 0, 127250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"17", {489250, 139250, 0, 133250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"18", {495250, 145250, 0, 139250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"19", {501250, 151250, 0, 145250, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"20", {507250, 157250, 0, 151250, 0, 0, 0, 0, 0, 0, 0, 0}},

  {"21", {513250, 163250, 0, 157250, 471250, 471250, 471250, 471250, 0, 471250, 0, 471250}},
  {"22", {519250, 169250, 0, 165250, 479250, 479250, 479250, 479250, 0, 479250, 0, 479250}},
  {"23", {525250, 217250, 0, 223250, 487250, 487250, 487250, 487250, 0, 487250, 0, 487250}},
  {"24", {531250, 223250, 0, 231250, 495250, 495250, 495250, 495250, 0, 495250, 0, 495250}},
  {"25", {537250, 229250, 0, 237250, 503250, 503250, 503250, 503250, 0, 503250, 0, 503250}},
  {"26", {543250, 235250, 0, 243250, 511250, 511250, 511250, 511250, 0, 511250, 0, 511250}},
  {"27", {549250, 241250, 0, 249250, 519250, 519250, 519250, 519250, 0, 519250, 0, 519250}},

  {"28",
   {555250, 247250, 0, 253250, 527250, 527250, 527250, 527250, 0, 527250, 527250, 527250}},
  {"29",
   {561250, 253250, 0, 259250, 535250, 535250, 535250, 535250, 0, 535250, 534250, 535250}},
  {"30",
   {567250, 259250, 0, 265250, 543250, 543250, 543250, 543250, 0, 543250, 541250, 543250}},
  {"31",
   {573250, 265250, 0, 271250, 551250, 551250, 551250, 551250, 0, 551250, 548250, 551250}},
  {"32",
   {579250, 271250, 0, 277250, 559250, 559250, 559250, 559250, 0, 559250, 555250, 559250}},
  {"33",
   {585250, 277250, 0, 283250, 567250, 567250, 567250, 567250, 0, 567250, 562250, 567250}},
  {"34",
   {591250, 283250, 0, 289250, 575250, 575250, 575250, 575250, 0, 575250, 569250, 575250}},
  {"35",
   {597250, 289250, 0, 295250, 583250, 583250, 583250, 583250, 0, 583250, 576250, 583250}},
  {"36",
   {603250, 295250, 0, 301250, 591250, 591250, 591250, 591250, 0, 591250, 0, 591250}},
  {"37",
   {609250, 301250, 0, 307250, 599250, 599250, 599250, 599250, 0, 599250, 0, 599250}},
  {"38",
   {615250, 307250, 0, 313250, 607250, 607250, 607250, 607250, 0, 607250, 0, 607250}},
  {"39",
   {621250, 313250, 0, 319250, 615250, 615250, 615250, 615250, 0, 615250, 604250, 615250}},
  {"40",
   {627250, 319250, 0, 325250, 623250, 623250, 623250, 623250, 0, 623250, 611250, 623250}},
  {"41",
   {633250, 325250, 0, 331250, 631250, 631250, 631250, 631250, 0, 631250, 618250, 631250}},
  {"42",
   {639250, 331250, 0, 337250, 639250, 639250, 639250, 639250, 0, 639250, 625250, 639250}},
  {"43",
   {645250, 337250, 0, 343250, 647250, 647250, 647250, 647250, 0, 647250, 632250, 647250}},
  {"44",
   {651250, 343250, 0, 349250, 655250, 655250, 655250, 655250, 0, 655250, 639250, 655250}},
  {"45",
   {657250, 349250, 663250, 355250, 663250, 663250, 663250, 663250, 0, 663250, 646250,
    663250}},
  {"46",
   {663250, 355250, 669250, 361250, 671250, 671250, 671250, 671250, 0, 671250, 653250,
    671250}},
  {"47",
   {669250, 361250, 675250, 367250, 679250, 679250, 679250, 679250, 0, 679250, 660250,
    679250}},
  {"48",
   {675250, 367250, 681250, 373250, 687250, 687250, 687250, 687250, 0, 687250, 667250,
    687250}},
  {"49",
   {681250, 373250, 687250, 379250, 695250, 695250, 695250, 695250, 0, 695250, 674250,
    695250}},
  {"50",
   {687250, 379250, 693250, 385250, 703250, 703250, 703250, 703250, 0, 703250, 681250,
    703250}},
  {"51",
   {693250, 385250, 699250, 391250, 711250, 711250, 711250, 711250, 0, 711250, 688250,
    711250}},
  {"52",
   {699250, 391250, 705250, 397250, 719250, 719250, 719250, 719250, 0, 719250, 695250,
    719250}},
  {"53",
   {705250, 397250, 711250, 403250, 727250, 727250, 727250, 727250, 0, 727250, 702250,
    727250}},
  {"54",
   {711250, 403250, 717250, 409250, 735250, 735250, 735250, 735250, 0, 735250, 709250,
    735250}},
  {"55",
   {717250, 409250, 723250, 415250, 743250, 743250, 743250, 743250, 0, 743250, 716250,
    743250}},
  {"56",
   {723250, 415250, 729250, 421250, 751250, 751250, 751250, 751250, 0, 751250, 723250,
    751250}},
  {"57",
   {729250, 421250, 735250, 427250, 759250, 759250, 759250, 759250, 0, 759250, 730250,
    759250}},
  {"58",
   {735250, 427250, 741250, 433250, 767250, 767250, 767250, 767250, 0, 767250, 737250,
    767250}},
  {"59",
   {741250, 433250, 747250, 439250, 775250, 775250, 775250, 775250, 0, 775250, 744250,
    775250}},
  {"60",
   {747250, 439250, 753250, 445250, 783250, 783250, 783250, 783250, 0, 783250, 751250,
    783250}},
  {"61",
   {753250, 445250, 759250, 451250, 791250, 791250, 791250, 791250, 0, 0, 758250,
    791250}},
  {"62",
   {759250, 451250, 765250, 457250, 799250, 799250, 799250, 799250, 0, 799250, 765250,
    799250}},
  {"63",
   {765250, 457250, 0, 463250, 807250, 807250, 807250, 807250, 0, 807250, 772250, 807250}},
  {"64",
   {771250, 463250, 0, 0, 815250, 815250, 815250, 815250, 0, 815250, 779250, 815250}},
  {"65",
   {777250, 469250, 0, 0, 823250, 823250, 823250, 823250, 0, 823250, 786250, 823250}},
  {"66",
   {783250, 475250, 0, 0, 831250, 831250, 831250, 831250, 0, 831250, 793250, 831250}},
  {"67",
   {789250, 481250, 0, 0, 839250, 839250, 839250, 839250, 0, 839250, 800250, 839250}},
  {"68",
   {795250, 487250, 0, 0, 847250, 847250, 847250, 847250, 0, 847250, 807250, 847250}},
  {"69",
   {801250, 493250, 0, 0, 855250, 855250, 855250, 855250, 0, 855250, 814250, 855250}},

  {"70", {807250, 499250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"71", {813250, 505250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"72", {819250, 511250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"73", {825250, 517250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"74", {831250, 523250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"75", {837250, 529250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"76", {843250, 535250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"77", {849250, 541250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"78", {855250, 547250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"79", {861250, 553250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"80", {867250, 559250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"81", {873250, 565250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"82", {879250, 571250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"83", {885250, 577250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"84", {0, 583250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"85", {0, 589250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"86", {0, 595250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"87", {0, 601250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"88", {0, 607250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"89", {0, 613250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"90", {0, 619250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"91", {0, 625250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"92", {0, 631250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"93", {0, 637250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"94", {0, 643250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"95", {0, 91250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"96", {0, 97250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"97", {0, 103250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"98", {0, 109250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"99", {0, 115250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"100", {0, 649250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"101", {0, 655250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"102", {0, 661250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"103", {0, 667250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"104", {0, 673250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"105", {0, 679250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"106", {0, 685250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"107", {0, 691250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"108", {0, 697250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"109", {0, 703250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"110", {0, 709250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"111", {0, 715250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"112", {0, 721250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"113", {0, 727250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"114", {0, 733250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"115", {0, 739250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"116", {0, 745250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"117", {0, 751250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"118", {0, 757250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"119", {0, 763250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"120", {0, 769250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"121", {0, 775250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"122", {0, 781250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"123", {0, 787250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"124", {0, 793250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"125", {0, 799250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},

  {"T7", {0, 8250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"T8", {0, 14250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"T9", {0, 20250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"T10", {0, 26250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"T11", {0, 32250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"T12", {0, 38250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}},
  {"T13", {0, 44250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}}
};






int get_symchan_frequency (const char * name, const char * tvnorm) {
  unsigned int i;
  int norm = 0;

  if (tvnorm == NULL) 
    tvnorm = "pal-europe";

  /* find index */
  for (i = 0; i < sizeof(chan_names) / sizeof(*chan_names); i++) {
    if (!strcmp(tvnorm,chan_names[i].str)) {
      norm = chan_names[i].nr;
      break;
    }
  }

  /* find channel */
  for (i = 0; i <  sizeof(tvtuner) / sizeof(*tvtuner); i++) {
    if (!strcmp(tvtuner[i].name, name)) {
      return tvtuner[i].freq[norm];
    }
  }
  return -1; /* not found */
}

struct channel {
  char name[100];
  char channel[100];
  int fine;
};


struct channel * channels;
int channels_size= 0;
void read_xawdecode_channels (void)
{
  FILE *fp;

  const char *xawfilename = ".xawdecode/xawdecoderc";
  char line[100], tag[32], val[100];
  char filename[1000];

  channels_size= 50;
  int act_channel = -1;
  int nr = 0;
  
  sprintf(filename,"%s/%s",getenv("HOME"), xawfilename);

  fp = fopen (filename, "r");
  if (NULL == fp) {
    channels_size = 0;
    fprintf (stderr, "Can't open config file %s:", filename);
    return;
  }
  channels = (struct channel *) malloc(channels_size*sizeof(*channels));
 
  while (NULL != fgets (line, 99, fp)) {
    nr++;
    if (strlen(line) < 2) continue; // ignore empty lines

    line[99] = '\0';
    if (1 == sscanf (line, "[%99[^]]]", val)) {
      act_channel++;
      if (act_channel >= channels_size) {
        channels_size *=2;
        channels = (struct channel *) realloc (channels, channels_size*sizeof(*channels));
      }
      strcpy(channels[act_channel].name , val);
      channels[act_channel].channel[0] = '\0';
      channels[act_channel].fine = 0;
      continue;
    }
    
    if (act_channel < 0) 
      continue; /* didn't see any channel header yet! */

    if (2 != sscanf (line, " %31[^= ] = %99[^\n]", tag, val))
    {
      fprintf (stderr, "%s:%d: parse error\n", filename, nr);
      continue;
    }
    
    /*    printf ("tag:%s val %s\n", tag, val);*/
    if (!strncmp(tag, "channel", 7)) {
      strcpy(channels[act_channel].channel, val);
    } else if (!strncmp(tag, "fine", 4)) {
      channels[act_channel].fine = atoi(val);
    }
  }

  channels_size = act_channel+1;
  fclose(fp);
}

void print_channels () {
  int i;
  if (!channels)
    read_xawdecode_channels();
  for (i = 0; i < channels_size; i++) {
    fprintf(stderr,"Channel #%d: %s  |  %s    (%d)\n", i+1, channels[i].name, channels[i].channel, channels[i].fine);
  }
}


double get_chan_frequency(const char *nameornumber, char *optional_namebuf) 
{
  int i;
  long asnumber = 0;
  char *endptr;

  if (!channels)
    read_xawdecode_channels();

  /* if name is just a number, take channel number. */
  asnumber = strtol(nameornumber, &endptr, 10);
  if (*endptr == '\0' /* string was a valid number */
      && asnumber > 0 && asnumber <= channels_size) {

    if (optional_namebuf)
      strncpy(optional_namebuf, channels[asnumber-1].name, 32);
    return get_symchan_frequency(channels[asnumber-1].channel,NULL)/1000.0;
  }
  

  /* not a number, search channel name */
  for (i = 0; i < channels_size; i++) {
    if (!strncmp(nameornumber, channels[i].name,strlen(nameornumber))) {
      if (optional_namebuf)
        strncpy(optional_namebuf, nameornumber, 32);
      return get_symchan_frequency(channels[i].channel,NULL)/1000.0;
    }
  }
  if (optional_namebuf)
    strcpy(optional_namebuf, "not found");
  return 0.0;
  
}

#if BUILD_MAIN
int main(int argc, char ** argv) 
{

  char buf[33];

  if (argc > 1) {
    double f = get_chan_frequency(argv[1],buf);
    printf("Frequency of %s(%s) is %f MHz\n", argv[1], buf, f);
  } else
    print_channels();

  return 0;
}
#endif
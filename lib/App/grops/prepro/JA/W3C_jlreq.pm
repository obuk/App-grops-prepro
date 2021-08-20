package App::grops::prepro::JA::W3C_jlreq;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

App::grops::prepro::JA::W3C_jlreq - It's new $module

=head1 SYNOPSIS

    use App::grops::prepro::JA::W3C_jlreq;

=cut

use feature 'say';
use Exporter 'import';
our @ISA = qw(Exporter);
our @EXPORT_OK = ();

{
  my $package = __PACKAGE__ . "::";
  no strict 'refs';
  push @EXPORT_OK, grep /^(In|Is)/, keys %{$package};
}

our %EXPORT_TAGS = (all => \@EXPORT_OK);

# A.1 Opening brackets (cl-01)
sub InOpeningBrackets {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
00AB;  «	LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
2018; ‘	LEFT SINGLE QUOTATION MARK	used horizontal composition
201C; “	LEFT DOUBLE QUOTATION MARK	used horizontal composition
0028;  (	LEFT PARENTHESIS
3014; 〔	LEFT TORTOISE SHELL BRACKET
005b;  [	LEFT SQUARE BRACKET
007b;  {	LEFT CURLY BRACKET
3008; 〈	LEFT ANGLE BRACKET
300A; 《	LEFT DOUBLE ANGLE BRACKET
300C; 「	LEFT CORNER BRACKET
300E; 『	LEFT WHITE CORNER BRACKET
3010; 【	LEFT BLACK LENTICULAR BRACKET
2985; ｟	LEFT WHITE PARENTHESIS
3018; 〘	LEFT WHITE TORTOISE SHELL BRACKET
3016; 〖	LEFT WHITE LENTICULAR BRACKET
301D; 〝	REVERSED DOUBLE PRIME QUOTATION MARK	used vertical composition
FF08; （	LEFT PARENTHESIS
FF3B; ［	LEFT SQUARE BRACKET
FF5B; ｛	LEFT CURLY BRACKET
END
}

# A.2 Closing brackets (cl-02)
sub InClosingBrackets {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
00BB; » 	RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
2019; ’	RIGHT SINGLE QUOTATION MARK	used horizontal composition
201D; ”	RIGHT DOUBLE QUOTATION MARK	used horizontal composition
0029; ) 	RIGHT PARENTHESIS
3015; 〕	RIGHT TORTOISE SHELL BRACKET
005D; ] 	RIGHT SQUARE BRACKET
007D; } 	RIGHT CURLY BRACKET
3009; 〉	RIGHT ANGLE BRACKET
300B; 》	RIGHT DOUBLE ANGLE BRACKET
300D; 」	RIGHT CORNER BRACKET
300F; 』	RIGHT WHITE CORNER BRACKET
3011; 】	RIGHT BLACK LENTICULAR BRACKET
2986; ｠	RIGHT WHITE PARENTHESIS
3019; 〙	RIGHT WHITE TORTOISE SHELL BRACKET
3017; 〗	RIGHT WHITE LENTICULAR BRACKET
301F; 〟	LOW DOUBLE PRIME QUOTATION MARK	used vertical composition
FF09; ）	RIGHT PARENTHESIS
FF3D; ］	RIGHT SQUARE BRACKET
FF5D; ｝	RIGHT CURLY BRACKET
END
}

# A.3 Hyphens (cl-03)
sub InHyphens {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
002d; - 	HYPHEN	quarter em width
2010; ‐ 	HYPHEN	quarter em width
301C; 〜	WAVE DASH
30A0; ゠	KATAKANA-HIRAGANA DOUBLE HYPHEN	half-width
2013; – 	EN DASH	half-width
END
}

# A.4 Dividing punctuation marks (cl-04)
sub InDividingPunctuationMarks {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
0021; ！	EXCLAMATION MARK
003F; ？	QUESTION MARK
203C; ‼	DOUBLE EXCLAMATION MARK
2047; ⁇	DOUBLE QUESTION MARK
2048; ⁈	QUESTION EXCLAMATION MARK
2049; ⁉	EXCLAMATION QUESTION MARK
FF01; ！	EXCLAMATION MARK
FF1F; ？	QUESTION MARK
END
}

# A.5 Middle dots (cl-05)
sub InMiddleDots {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
30FB; ・	KATAKANA MIDDLE DOT
00B7; ·		Middle Dot
END
}

sub InColon {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
003A; ：	COLON
FF1A; ：	COLON
003B; ；	SEMICOLON	used horizontal composition
FF1B; ；	SEMICOLON	used horizontal composition
END
}

# A.6 Full stops (cl-06)
sub InFullStops {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
3002; 。	IDEOGRAPHIC FULL STOP
002E; . 	FULL STOP	used horizontal composition
FF0E; ．	FULL STOP	used horizontal composition
END
}

# A.7 Commas (cl-07)
sub InCommas {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
3001; 、	IDEOGRAPHIC COMMA
002C; ，	COMMA	used horizontal composition
FF0C; ，	COMMA	used horizontal composition
END
}

# A.8 Inseparable characters (cl-08)
sub InInseparableCharacters {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
2014; —	EM DASH	Some systems implement U+2015 HORIZONTAL BAR very similar behavior to U+2014 EM DASH
2026; …	HORIZONTAL ELLIPSIS
2025; ‥	TWO DOT LEADER
3033; 〳	VERTICAL KANA REPEAT MARK UPPER HALF	used vertical compositionU+3035 follows this
3034; 〴	VERTICAL KANA REPEAT WITH VOICED SOUND MARK UPPER HALF	used vertical compositionU+3035 follows this
3035; 〵	VERTICAL KANA REPEAT MARK LOWER HALF	used vertical composition
END
}

# A.9 Iteration marks (cl-09)
sub InIterationMarks {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
3005; 々	IDEOGRAPHIC ITERATION MARK
303B; 〻	VERTICAL IDEOGRAPHIC ITERATION MARK
309D; ゝ	HIRAGANA ITERATION MARK
309E; ゞ	HIRAGANA VOICED ITERATION MARK
30FD; ヽ	KATAKANA ITERATION MARK
30FE; ヾ	KATAKANA VOICED ITERATION MARK
END
}

# A.10 Prolonged sound mark (cl-10)

# A.11 Small kana (cl-11)

# A.12 Prefixed abbreviations (cl-12)
sub InPrefixedAbbreviations {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
00A3; ￡	POUND SIGN
FFE1; ￡	POUND SIGN
0024; ＄	DOLLAR SIGN
FF04; ＄	DOLLAR SIGN
00A5; ￥	YEN SIGN
FFE5; ￥	YEN SIGN
20AC; € 	EURO SIGN
0023; ＃	NUMBER SIGN
FF03; ＃	NUMBER SIGN
2116; №	NUMERO SIGN
END
}

# A.13 Postfixed abbreviations (cl-13)
sub InPostfixedAbbreviations {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
00B0; °	DEGREE SIGN	proportional
2032; ′	PRIME	proportional
2033; ″	DOUBLE PRIME	proportional
2103; ℃	DEGREE CELSIUS
00A2; ￠	CENT SIGN
0025; ％	PERCENT SIGN
FF05; ％	PERCENT SIGN
2030; ‰	PER MILLE SIGN
33CB; ㏋	SQUARE HP
2113; ℓ 	SCRIPT SMALL L
3303; ㌃	SQUARE AARU
330D; ㌍	SQUARE KARORII
3314; ㌔	SQUARE KIRO
3318; ㌘	SQUARE GURAMU
3322; ㌢	SQUARE SENTI
3323; ㌣	SQUARE SENTO
3326; ㌦	SQUARE DORU
3327; ㌧	SQUARE TON
332B; ㌫	SQUARE PAASENTO
3336; ㌶	SQUARE HEKUTAARU
333B; ㌻	SQUARE PEEZI
3349; ㍉	SQUARE MIRI
334A; ㍊	SQUARE MIRIBAARU
334D; ㍍	SQUARE MEETORU
3351; ㍑	SQUARE RITTORU
3357; ㍗	SQUARE WATTO
338E; ㎎	SQUARE MG
338F; ㎏	SQUARE KG
339C; ㎜	SQUARE MM
339D; ㎝	SQUARE CM
339E; ㎞	SQUARE KM
33A1; ㎡	SQUARE M SQUARED
33C4; ㏄	SQUARE CC
END
}

# A.14 Full-width ideographic space (cl-14)

# A.15 Hiragana (cl-15)

# A.16 Katakana (cl-16)

# A.17 Math symbols (cl-17)

# A.18 Math operators (cl-18)

# A.19 Ideographic characters (cl-19)

# A.20 Characters as reference marks (cl-20)

# A.21 Ornamented character complexes (cl-21)

# A.22 Simple-ruby character complexes (cl-22)

# A.23 Jukugo-ruby character complexes (cl-23)

# A.24 Grouped numerals (cl-24)

sub InGroupedNumerals {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
0020; 		SPACE	quarter em width
002C;		, 	COMMA 	quarter em width or half-width
002E;		. 	FULL STOP decimal point, quarter em width or half-width
0030 0039;	0-9
END
}

# A.25 Unit symbols (cl-25)
sub InUnitSymbols {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
0020;	 	SPACE	quarter em width
0028;	( 	LEFT PARENTHESIS
0029;	) 	RIGHT PARENTHESIS
002F;	\/ 	SOLIDUS one third em width, half-width or proportional
0031 0034;	DIGIT ONE - FOUR 1 - 4 	half-width or proportional
0041 005A;	LATIN CAPITAL LETTER A - Z	proportionally-spaced
0061 007A;	LATIN SMALL LETTER A - Z	proportionally-spaced
03A9;	Ω	GREEK CAPITAL LETTER OMEGA	proportionally-spaced
03BC;	μ	GREEK SMALL LETTER MU	proportionally-spaced
2127;	℧	INVERTED OHM SIGN 	proportionally-spaced
212B;	Å	ANGSTROM SIGN 	 	proportionally-spaced
2212;	− 	SIGN
30FB;	・ 	KATAKANA MIDDLE DOT	half-width
END
}

# A.26 Western word space (cl-26)

# A.27 Western characters (cl-27)
sub InWesternCharacters {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
0021 007E
00A0 00B4
00B6 0109
010C 010F
0111 0113
0118 011D
0124 0125
0127 0127
012A 012B
0134 0135
0139 013A
013D 013E
0141 0144
0147 0148
014B 014D
0150 0155
0158 0165
016A 0171
0179 017E
0193 0193
01C2 01C2
01CD 01CE
01D0 01D2
01D4 01D4
01D6 01D6
01D8 01D8
01DA 01DA
01DC 01DC
01F8 01F9
01FD 01FD
0250 025A
025C 025C
025E 0261
0264 0268
026C 0273
0275 0275
0279 027B
027D 027E
0281 0284
0288 028E
0290 0292
0294 0295
0298 0298
029D 029D
02A1 02A2
02C7 02C8
02CC 02CC
02D0 02D1
02D8 02D9
02DB 02DB
02DD 02DE
02E5 02E9
0300 0304
0306 0306
0308 0308
030B 030C
030F 030F
0318 031A
031C 0320
0324 0325
0329 032A
032C 032C
032F 0330
0334 0334
0339 033D
0361 0361
0391 03A1
03A3 03A9
03B1 03C9
0401 0401
0410 044F
0451 0451
1E3E 1E3F
1F70 1F73
2010 2010
2013 2014
2016 2016
2018 2019
201C 201D
2020 2022
2025 2026
2030 2030
2032 2033
203E 203F
2042 2042
2051 2051
20AC 20AC
210F 210F
2127 2127
212B 212B
2135 2135
2153 2155
2190 2194
2196 2199
21C4 21C4
21D2 21D2
21D4 21D4
21E6 21E9
2200 2200
2202 2203
2205 2205
2207 2209
220B 220B
2212 2213
221A 221A
221D 2220
2225 222C
222E 222E
2234 2235
223D 223D
2243 2243
2245 2245
2248 2248
2252 2252
2260 2262
2266 2267
226A 226B
2276 2277
2282 2287
228A 228B
2295 2297
22A5 22A5
22DA 22DB
2305 2306
2312 2312
2318 2318
23CE 23CE
2423 2423
2460 2473
24D0 24E9
24EB 24FE
25A0 25A1
25B1 25B3
25B6 25B7
25BC 25BD
25C0 25C1
25C6 25C7
25CB 25CB
25CE 25D3
25E6 25E6
25EF 25EF
2600 2603
2605 2606
260E 260E
261E 261E
2640 2640
2642 2642
2660 2667
2669 266F
2713 2713
2756 2756
2776 277F
2934 2935
29FA 29FB
3251 325F
32B1 32BF
#AC00 D7AF; Hangul Syllables
END
}

# A.28 Warichu opening brackets (cl-28)

# A.29 Warichu closing brackets (cl-29)

# A.30 Characters in tate-chu-yoko (cl-30)

1;
__END__

=head1 DESCRIPTION

App::grops::prepro::JA::W3C_jlreq is ...

=head1 LICENSE

Copyright (C) KUBO, Koichi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

KUBO, Koichi E<lt>k@obuk.orgE<gt>

=cut


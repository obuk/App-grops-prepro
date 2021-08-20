package App::grops::prepro::JA::CC;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

App::grops::prepro::JA::CC - It's new $module

=head1 SYNOPSIS

    use App::grops::prepro::JA::CC;

=cut

use App::grops::prepro::JA::W3C_jlreq ':all';

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


# user-defined props (alphabetical order)
sub InEnding {
  return <<END;
+utf8::InClose_Punctuation
+utf8::InFinal_Punctuation
+InColon
+InFullStops
+InCommas
+InDividingPunctuationMarks
END
}

sub InEndingJ {
  return <<END;
+InEnding
&InJapaneseCharacters
END
}


sub InEndingW {
  return <<END;
+InEnding
&InWesternCharacters
END
}


sub InIVS {
  "E0100 E01EF";
}


sub InJapanese {
  return <<END;
+InJapaneseCharacters
-InSVS
-InIVS
-InPunctuations
END
}


sub InJapaneseCharacters {
  # see $Config{privlib}/unicore/Blocks.txt
  (my $u = <<END) =~ s/[#;].*//gm; $u;
3000 303F; CJK Symbols and Punctuation
3040 309F; Hiragana
30A0 30FF; Katakana
3190 319F; Kanbun
31C0 31EF; CJK Strokes
31F0 31FF; Katakana Phonetic Extensions
3200 32FF; Enclosed CJK Letters and Months
3300 33FF; CJK Compatibility
3400 4DBF; CJK Unified Ideographs Extension A
4DC0 4DFF; Yijing Hexagram Symbols
4E00 9FFF; CJK Unified Ideographs
F900 FAFF; CJK Compatibility Ideographs
FE00 FE0F; Variation Selectors
FF00 FFEF; Halfwidth and Fullwidth Forms
20000 2A6DF; CJK Unified Ideographs Extension B
2A700 2B73F; CJK Unified Ideographs Extension C
2B740 2B81F; CJK Unified Ideographs Extension D
2B820 2CEAF; CJK Unified Ideographs Extension E
2CEB0 2EBEF; CJK Unified Ideographs Extension F
2F800 2FA1F; CJK Compatibility Ideographs Supplement
E0100 E01EF; Variation Selectors Supplement
END
}


sub InMiddleDotsJ {
  return <<END;
+InMiddleDots
&InJapaneseCharacters
END
}


sub InPunctuations {
  return <<END;
+InStarting
+InEnding
+InHyphens
+InMiddleDots
+utf8::InPunctuation
+utf8::InSymbol
END
}


sub InStarting {
  return <<END;
+utf8::InOpen_Punctuation
+utf8::InInitial_Punctuation
END
}


sub InStartingJ {
  return <<END;
+InStarting
&InJapaneseCharacters
END
}


sub InStartingW {
  return <<END;
+InStarting
&InWesternCharacters
END
}


sub InSVS {
  "FE00 FE0F";
}


sub InUnitSymbolsSimple {
  (my $u = <<END) =~ s/[#;].*//gm; $u;
+InUnitSymbols
-0020;	 	SPACE	quarter em width
-0028;	( 	LEFT PARENTHESIS
-0029;	) 	RIGHT PARENTHESIS
-002F;	\/ 	SOLIDUS one third em width, half-width or proportional
END
}


=begin comment

\p {InUSPC} is a user-defined property that matches spaces in the man
page source code.  This property also includes spaces created by
roff's escape \/, \^, \|, \h'nnn', etc., but not \n.  \n is used to
connect multiple continuation lines.

=end comment

=cut

sub InUSPC {
  return <<END;
+utf8::InSpace
-000A
+InSPC
END
}


sub InWestern {
  return <<END;
+InWesternCharacters
-InJapaneseCharacters
END
}

1;

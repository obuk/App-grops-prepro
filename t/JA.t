#! perl

use strict;
use warnings;
use utf8;
use Test::More;
use Test::Trap;
use File::Temp;

my $builder = Test::More->builder;
binmode $builder->output,         ":encoding(utf8)";
binmode $builder->failure_output, ":encoding(utf8)";
binmode $builder->todo_output,    ":encoding(utf8)";

use App::grops::prepro::JA;

sub preconv {
  my ($s) = @_;
  for ($s) {
    s{[^[:ascii:]]}{
      my @u = unpack "U*", $&;
      sprintf "\\[u".join('_', ("%04X") x @u)."]", @u;
    }eg;
  }
  $s;
}

sub pp0 {
  my $s = shift;
  my %opts = (
    prologue => "",
    zwsp => "",
    wdsp => " ",
    nrsp => "",
    @_,
  );
  trap {
    my $in = File::Temp->new(UNLINK => 1);
    print $in preconv($s);
    $in->seek(0, 0);
    local *ARGV = $in;
    App::grops::prepro::JA->run(\%opts);
  };
  chomp(my $out = $trap->stdout);
  $out;
}

sub pp1 {
  my $s = shift;
  chomp($s);
  pp0($s . "\n", @_);
}

# add DNL to disable line breaks between ja and ja lines.
is pp0("line\n"), preconv("line"), "w newline";
is pp0("line"), preconv("line\\c"), "wo newline";
is pp0("行\nline\n"), preconv("行\nline"), "ja-\\n-we";
is pp0("改行\n無効\n"), preconv("改行\\c\n無効"), "ja-\\n-ja";
is pp0("改行\\c\n無効\n"), preconv("改行\\c\n無効"), "ja-\\c\\n-ja";

# add / to \p{InInseparableCharacters}
is pp1("YY/MM/DD"), preconv("YY/MM/DD"), "is1 w/w/w";
is pp1("年/月/日"), preconv("年/月/日"), "is2 j/j/j";
is pp1("09/12/34"), preconv("09/12/34"), "is3 n/n/n";

# remove \p{InPSPC} in quotes
is pp1("q1 'joe' we"), preconv("q1 'joe' we"), "q1 'joe' we";
is pp1("q2 \"joe\" we"), preconv("q2 \"joe\" we"), "q2 \"joe\" we";
is pp1("q3 `joe' we"), preconv("q3 `joe' we"), "q3 `joe' we";
is pp1("q1 '太朗' ja"), preconv("q1 '太朗' ja"), "q1 '太朗' ja";
is pp1("q2 \"太朗\" ja"), preconv("q2 \"太朗\" ja"), "q2 \"太朗\" ja";
is pp1("q3 `太朗' ja"), preconv("q3 `太朗' ja"), "q3 `太朗' ja";

done_testing;

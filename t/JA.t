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

done_testing;

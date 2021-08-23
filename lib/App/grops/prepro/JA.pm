package App::grops::prepro::JA;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.02";

use feature qw/say/;
use parent 'App::grops::prepro';

use utf8;
use App::grops::prepro::JA::CC ':all';
use Class::Accessor 'antlers';

sub InPUA       { "F0000 FFFFF" }
sub InPSPC      { "F0000 F000F" } # <-> InUSPC
sub InDNL       { "F0010 F01FF" }
sub InSPC       { "F0200 F0FFF" }
sub InESC       { "F1000 F1FFF" }
sub InFCD       { "F2000 F2FFF" }
sub InNUM       { "F3000 F3FFF" }

has emsp        => (is => 'rw');
has hemsp       => (is => 'rw');
has qemsp       => (is => 'rw');
has zwsp        => (is => 'rw');
has nrsp        => (is => 'rw');
has wdsp        => (is => 'rw');
has cr          => (is => 'rw');

has re_num      => (is => 'rw');
has re_mode     => (is => 'rw');
has re_spc      => (is => 'rw');
has re_esc      => (is => 'rw');
has fc          => (is => 'rw');

sub m_punct     { (1 << 0) }
sub m_zwsp      { (1 << 1) }
sub m_wdsp      { (1 << 2) }
sub m_nrsp      { (1 << 4) }
sub m_cr        { (1 << 5) }

sub init {
  my ($self) = @_;

  eval { require Unicode::Normalize };

  #$self->debug(16);

  unless (defined $self->lang) {
    $self->lang((split '::', __PACKAGE__)[-1]);
  }

  unless (defined $self->mode) {
    $self->mode(m_punct | m_zwsp | m_wdsp | m_nrsp);
  }

  unless (defined $self->re_mode) {
    $self->re_mode(qr/\\"\s*pp-ja/);
  }

  unless (defined $self->prologue()) {
    $self->prologue(<<'END');
.nr pp:debug 0
.ds pp:color orange
.de pp:cr
\c
.  if (\\n[pp:debug]) \{\
.    ie '\\*[pp:color]'' .nop \(CR\c
.    el .nop \m[\\*[pp:color]]\(CR\m[]\c
.  \}
..
.de pp:sp
\c
.  nr \\$0.ss  \\n[.ss]
.  nr \\$0.sss \\n[.sss]
.  ss
.  ie \\n[.$] .ss \\$*
.  el .ss \\n[\\$0-width]
.  nr \\$0-w (\\n[.ss]*100)u
.  if (\\n[pp:debug])&(\\n[.ss]) \{\
.    ie '\\*[pp:color]'' .nop \Z'\D'l 0 +0.1'\D'l +\\n[\\$0-w]u 0''\c
.    el .nop \m[\\*[pp:color]]\Z'\D'l 0 +0.1'\D'l +\\n[\\$0-w]u 0''\m[]\c
.  \}
.  nop \& \c
.  if (\\n[pp:debug])&(\\n[.ss]) \{\
.    ie '\\*[pp:color]'' .nop \Z'\D'l 0 +0.1'\D'l -\\n[\\$0-w]u 0''\c
.    el .nop \m[\\*[pp:color]]\Z'\D'l 0 +0.1'\D'l -\\n[\\$0-w]u 0''\m[]\c
.  \}
.  ss
.  ss \\n[\\$0.ss] \\n[\\$0.sss]
..
.nr pp:emsp-width  (\n[.ss] * 320 / 100)
.nr pp:hemsp-width (\n[.ss] * 160 / 100)
.nr pp:qemsp-width (\n[.ss] *  80 / 100)
.nr pp:nrsp-width  (\n[.ss] *  20 / 100)
.nr pp:wdsp-width  (\n[.ss])
.nr pp:zwsp-width  0
.
.als pp:emsp  pp:sp
.als pp:hemsp pp:sp
.als pp:qemsp pp:sp
.als pp:nrsp  pp:sp
.als pp:wdsp  pp:sp
.als pp:zwsp  pp:sp
END
  }

  $self->emsp("\\*[pp:emsp ]")   unless defined $self->emsp;
  $self->hemsp("\\*[pp:hemsp ]") unless defined $self->hemsp;
  $self->qemsp("\\*[pp:qemsp ]") unless defined $self->qemsp;
  $self->wdsp("\\*[pp:wdsp ]")   unless defined $self->wdsp;
  $self->nrsp("\\*[pp:nrsp ]")   unless defined $self->nrsp;
  $self->zwsp("\\*[pp:zwsp ]")   unless defined $self->zwsp;

  $self->cr("\\*[pp:cr ]")       unless defined $self->cr;

  unless (defined $self->re_spc) {
    $self->re_spc(
      qr/ \\ (?:
            \/                    # Ligatures and Kerning
          | \,
          | \&
          | \)

          | v (?: '[^']*' | \[ [^\]]* \] ) # Page Motions
          | r
          | u
          | d
          | h (?: '[^']*' | \[ [^\]]* \] )
          | \x{20}
          | \~
          | \|
          | \^
          | 0
          | w '[^']*'
          | k (?&name)
          | o '[^']*'
          | z (?&glyph)
          | Z '[^']*'
          )
          (?(DEFINE)
            (?<ident> [^\s\x{00}\x{01}\x{0B}\x{0D}-\x{1F}\x{80}-\x{9F}]+ )
            (?<name>  [^\[\(] | \( .. | \[ [^\]]* \] )
            (?<glyph> \\ (?&name) | [^\\] )
            (?<size> [+\-]?\d | \([+\-]?\d\d )
          )
        /mx
      );
  }

  unless (defined $self->re_num) {
    $self->re_num(
      qr/ (?&pre)? (?&num) (?&post)?
          (?(DEFINE)
            (?<pre> \p{InPrefixedAbbreviations}+ )
            (?<num> \d+ (?: (?:[.,]\p{InUSPC}?) \d+ )* )
            (?<post> (?: \p{InPostfixedAbbreviations} | \p{InUnitSymbolsSimple} )+
            | \p{InUSPC}* [(\[] [^\)\]]+ [)\]] )
          )
        /x
      );
  }

  $self->SUPER::init;

  for (qw/ IsEmSp IsHEmSp IsQEmSp IsWdSp IsNrSp IsZwSp /) {
    /^Is(.*)/;
    my $sp = lc($1);
    my $_sp = "_$sp";
    my $c = $self->pua_char($_, \&InPSPC);
    $self->pua_char($self->$sp, $c);
    eval sprintf 'sub %s { "%X" }', $_, ord $c;
    eval sprintf 'sub %s { "\\x{%X}" }', $_sp, ord $c;
  }

  $self;
}


sub prepro {
  my ($self) = @_;

  my $req  = $self->re_req;
  my $mode = $self->re_mode;

  if ($mode) {
    if (my ($e) = /$req\s*(\p{InESC})/) {
      if ($self->pua->{$e} =~ /$mode(?:\s+(\d+))?/) {
        $self->mode($1);
      }
    }
  }
  if (/$req\s*fc(?:\s+(.)(.)?)?$/) {
    if (defined $1) {
      $self->fc(sprintf "\\x{%X}", ord $1);
    } else {
      $self->fc(undef);
    }
  } elsif (/$req/) {

    if (/$req\s*Sh\s+(名前|名称)\b/) {
      $_ = join "\n",
        ".ds section-name $1",
        ".ds doc-section-name $1",
        ".lf $.",
        $_;
    }

  } else {

    my $m = $self->mode;

    if (my $delim = $self->fc) {
      s/${delim}.*${delim}/$self->pua_char($&, \&InFCD)/e;
    }

    if ($m & m_zwsp) {
      s{\p{InJapanese}{2,}|[\p{InSVS}\p{InIVS}]\p{InJapanese}}{
        join $self->_zwsp(), split //, $&;
      }eg;

      s{(\p{InJapanese})(\p{InDNL}\n)(\p{InJapanese})}{
        my ($j1, $c, $j2) = ($1, $2, $3);
        ($j1 =~ /\p{InStarting}/ || $j2 =~ /\p{InEnding}/)?
          $j1.$c.$j2 : $j1.$self->_zwsp().$c.$j2;
      }eg;
    }

    if ($m & m_wdsp) {
      s{(\p{InJapanese}[\p{InSVS}\p{InIVS}]?)(\p{InWestern})}{do {
        my ($x, $p) = ($1, $2);
        ($p =~ /^\p{InEnding}/)? $x.$p : $x.$self->_wdsp().$p;
      }}eg;

      s{(\p{InWestern})(\p{InJapanese})}{do {
        my ($p, $x) = ($1, $2);
        ($p =~ /\p{InStarting}$/)? $p.$x : $p.$self->_wdsp().$x;
      }}eg;
    }

    if ($m & m_nrsp) {
      if (my $number = $self->re_num) {
        s{$number}{$self->pua_char($&, \&InNUM)}egx;
        s{(\p{InJapanese}[\p{InSVS}\p{InIVS}]?)\p{IsWdSp}*(\p{InNUM})}{
          $1.$self->_nrsp.$2;
        }egx;
        s{(\p{InNUM})\p{IsWdSp}*(\p{InJapanese})}{
          $1.$self->_nrsp.$2;
        }egx;
      }
    }

    if ($m & m_punct) {
      # 3.1.2
      s/\p{InPSPC}*(\p{InStartingJ})/
        $self->_hemsp().$1/eg;
      s/(\p{InEndingJ})\p{InPSPC}*/
        $1.$self->_hemsp()/eg;
      s/\p{InPSPC}*(\p{InMiddleDotsJ}+)\p{InPSPC}*/
        $self->_qemsp().$1.$self->_qemsp()/eg;

      s/(\p{InJapanese}[\p{InSVS}\p{InIVS}]?)(\p{InStartingW})/
        $1.$self->_wdsp().$2/eg;
      s/(\p{InEndingW})(\p{InJapanese})/
        $1.$self->_wdsp().$2/eg;

      # 3.1.4
      s/\p{InPSPC}+(\p{InEnding})/$1/g;
      s/(\p{InStarting})\p{InPSPC}+/$1/g;

    }

    # remove \p{InPSPC} in quotes
    s/([\`\'\"])\p{InPSPC}+(.*?)\p{InPSPC}+([\'\"])/do {
      $1.$2.$3;
    }/eg;

    # remove \p{InPSPC} around \p{InInsep} characters
    s/\p{InPSPC}*(\p{InInsep}+)\p{InPSPC}*/$1/g;

    # to prefer input, remove \p{InPSPC} adjacent to \p{InUSPC}.
    s/\p{InPSPC}+(\p{InUSPC})/$1/g;
    s/(\p{InUSPC})\p{InPSPC}+/$1/g;

    s/^\p{InPSPC}+//sg;
    s/\p{InPSPC}+$//sg;

    if ($m & m_cr) {
      s/$/$self->cr/meg;
    }

  }
}

sub mode {
  my $self = shift;
  $self->{mode} //= [];
  if (@_) {
    if (defined $_[0]) {
      push @{$self->{mode}}, $_[0];
    } else {
      pop @{$self->{mode}};
    }
  }
  ${$self->{mode}}[-1];
}


sub gets {
  my ($self) = @_;

  return undef unless defined $self->SUPER::gets();

  my $m = $self->mode;

  my $req = $self->re_req;
  my $ec = $self->pua_char("\\c", \&InDNL);

  while (defined && !/$req/ && !($m & m_cr) && /\p{InJapaneseCharacters}$/) {
    my $line = $_;
    if (defined $self->SUPER::gets()) {
      if (!($m & m_cr) && /^\p{InJapaneseCharacters}/) {
        $line .= $ec . "\n" . $_;
        $_ = $line;
      } else {
        push @{$self->{unget}}, $_;
        $_ = $line;
        last;
      }
    } else {
      $_ = $line;
      last;
    }
  }

  return $_;

}

sub putline {
  my ($self) = @_;

  s{([^[:ascii:]\p{InSVS}\p{InIVS}])([\p{InSVS}\p{InIVS}])?}{
    my ($u, $vs) = ($1, $2);
    if (__PACKAGE__->can('NFD')) {
      $u = NFD($u);
    }
    my @u = unpack "U*", $u;
    push @u, unpack "U*", $vs if $vs;
    sprintf "\\[u".join('_', ("%04X") x @u)."]", @u;
  }eg;

  say;
}


sub getline {
  my ($self) = @_;

  my $esc = $self->re_esc;
  $esc = qr/$esc/;

  my $dnl = $self->re_dnl;
  my $spc = $self->re_spc;

  if (defined ($_ = shift @{$self->{unget}})) {
    ;
  } elsif (defined ($_ = <>)) {
    my $newline = chomp;

    1 while s{$esc}{
      my $e = $&;
      if ($e =~ /^$spc$/) {
        $self->pua_char($e, \&InSPC);
      } elsif ($e =~ /^$dnl$/) {
        $self->pua_char($e, \&InDNL);
      } elsif ($e =~ /^\\\[u([0-9A-F_]+)\]/) {
        my @u = map { pack "U", hex } split '_', $1;
        my $vs;
        if ($u[-1] =~ /[\p{InSVS}\p{InIVS}]/) {
          $vs = pop @u;
        }
        my $u = join '', @u;
        if (__PACKAGE__->can('NFC')) {
          $u = NFC($u);
        }
        $u .= $vs if $vs;
        $u;
      } else {
        $self->pua_char($e, \&InESC)
      }
    }e;

    $_ .= $self->pua_char("\\c", \&InDNL) unless $newline;

  }

  $_;
}

1;
__END__

=encoding utf-8

=head1 NAME

App::grops::prepro::JA - groff grops prepro

=head1 SYNOPSIS

    use App::grops::prepro::JA;
    exit(App::grops::prepro::JA->run);

=head1 DESCRIPTION

App::grops::prepro::JA works as a prepro when printing to ps or pdf
devices with groff, adding spaces to Japanese text.

=head1 LICENSE

Copyright (C) KUBO, Koichi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

KUBO, Koichi E<lt>k@obuk.orgE<gt>

=cut


package App::grops::prepro;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.13";

BEGIN {
  if (my @p5lib = map +(split ':'), grep defined, $ENV{PERL5LIB}) {
    use lib @p5lib;
  }
}

use feature qw/say/;

use Class::Accessor 'antlers';
use Encode;
use File::Basename;
use Getopt::Long;
use Data::Clone 'clone';

sub InPUA       { "F0000 FFFFF" }
sub InESC       { "F1000 F1FFF" }

has prologue    => (is => 'rw');
has re_req      => (is => 'rw');
has re_esc      => (is => 'rw');
has pua         => (is => 'rw');
has pua_saving  => (is => 'rw');
has end         => (is => 'rw');
has unget       => (is => 'rw');
has tee         => (is => 'rw');
has lang        => (is => 'rw');
has debug       => (is => 'rw');

has er          => (is => 'rw');
has ec          => (is => 'rw');

sub init {
  my ($self) = @_;

  $self->debug(0)  unless defined $self->debug;
  $self->pua({})   unless defined $self->pua;

  $self->unget([]) unless defined $self->unget;
  $self->end([])   unless defined $self->end;

  unless (defined $self->re_req) {
    $self->re_req(
      qr/ [.'] /x
    );
  }

  unless (defined $self->re_esc) {
    $self->re_esc(
      qr/ \\ (?&term)
          (?(DEFINE)
            (?<ident> [^\s\x{00}\x{01}\x{0B}\x{0D}-\x{1F}\x{80}-\x{9F}]+ )
            (?<name>  [^\[\(] | \( .. | \[ [^\]]* \] )
            (?<glyph> \\ (?&name) | [^\\] )
            (?<size> [+\-]?\d | \([+\-]?\d\d )
            (?<string> ' (?: \\ (?&term) | [^\'] ) * ' )
            (?<term> (?:
                \! .* $
              | \" .* $
              | \# .* $
              | \$ (?: (?&name) | \* | 0 | \@ | \^ )
              | \%
              | \&
              | \'
              | \)
              | \* (?&name)
              | \,
              | \-
              | \.
              | \/
              | 0
              | :
              | \? .*? \\\?
              | A (?&ident)
              | a
              | B (?&string)
              | b (?&string)
              | c # .* $
              | C (?&string)
              | d
              | D (?&string)
              | e
              | E
              | f (?&name)
              | F (?&name)
              | g (?&name)
              | H (?&string)
              | h (?&string)
              | k (?&name)
              | l (?&string)
              | L (?&string)
              | m (?&name)
              | M (?&name)
              | n (?&name)
              | o (?&string)
              | p
              | R (?&string)
              | r
              | $
              | S (?&string)
              | s (?&size)
              | \x{20}
              | u
              | t
              | v (?&string)
              | w (?&string)
              | x (?&string)
              | X (?&string)
              | Y (?&name)
              | Z (?&string)
              | z (?&glyph)
              | \\
              | \^
              | \_
              | \'
              | \`
              | \{
              | \|
              | \}
              | \~
              | \[ [^\]]* \]
              | \( ..
              )
            )
          )
        /mx
      );
  }

  $self->er("\\")  unless defined $self->er;
  $self->ec("\\c") unless defined $self->ec;

  for my $e (qw/ er ec /) {
    my $c = $self->pua_char($self->$e, \&InESC);
    no warnings 'redefine';
    eval sprintf 'sub _%s { "\\x{%X}" }', $e, ord $c;
  }

  $self;
}


sub run {
  my $class = shift;
  $class->new(@_)->process();
}


sub new {
  my $class = shift;
  $class->SUPER::new(@_)->init();
}


sub process {
  my ($self) = @_;

  my @prepro;
  my $troff = join '', grep defined, $ENV{GROFF_COMMAND_PREFIX}, 'troff';
  push @prepro, shift @ARGV while @ARGV && $ARGV[0] ne $troff;
  my @troff = @ARGV;
  shift @ARGV;

  my %opt;
  Getopt::Long::Configure("bundling");
  GetOptions((map +($_ => sub { $opt{$_[0]}++ }), qw/a b c i v z C E R U/),
             (map +("$_=s@" => sub { $opt{$_[0]}{$_[1]}++ }), qw/w W d f m n o r T F I M/));

  # Extract the country code contained in the -d and -m options
  # specified on the command line to invoke the language-dependent
  # preprocessing module.

  unless (defined $self->lang) {
    my @lang = map { /^locale=(([^._]*)(_[^.]*)?)(?:[.](.*))?/ ? ($2, $3 ? $1 : ()) : () } keys %{$opt{d}};
    for (@lang, keys %{$opt{m}}) {
      my $lang_class = join '::', ref $self, uc($_);
      if (do { eval "use $lang_class"; !$@ }) {
        local @ARGV = (@prepro, @troff);
        return $lang_class->run({%$self, lang => $_});
      }
    }
  }

  # show subprograms version
  say join ' ', basename($0), "version", $VERSION, ref $self
    if grep defined && $_ eq -v, @prepro;

  if (@troff) {
    local $ENV{PATH} = join ':', grep defined, $ENV{GROFF_BIN_PATH}, $ENV{PATH};
    open STDOUT, "|-", @troff or die usage();
  } elsif (@troff) {
    unshift @ARGV, @troff;
    @troff = ();
  }

  my $tee = $self->tee;
  open STDOUT, "|-", "tee", $tee or die "can't open $tee: $!" if $tee;
  $self->prepro_main if !grep $_ eq -v, @prepro;
  close STDOUT;
  return ($? >> 8);
}


sub usage {
  my @usage = (@_, "\n") if @_;
  push @usage, "usage: ", basename($0), " grops-opts troff troff-opts", "\n";
  @usage;
}

sub prepro_main {
  my ($self) = @_;
  if (my $prologue = $self->prologue) {
    $self->puts($prologue);
    $self->puts(".lf " . ($. // 0));
  }
  my $oldpua = $self->pua();
  do {
    $self->pua(clone($oldpua)) if $self->pua_saving;
  } while ($self->prepro_line);
  $self->pua_stats() if $self->debug & 32;
}


sub prepro_line {
  my ($self) = @_;

  my $req = $self->re_req;
  while (defined $self->gets()) {
    if ($self->debug & 1) {
      my @line = split /\n/;
      my $nr = $. + 1 - @line - grep defined, map +(split /\n/), @{$self->unget};
      my $i = 0;
      for (@line) {
        s/\p{InPUA}/$self->pua->{$&}/eg;
        printf STDERR "%6d%s %s\n", $nr + $i, $i == 0? ':' : '*', $_;
        $i++;
      }
    }
    if (@{$self->end}) {
      my $end = $self->end->[-1];
      pop @{$self->end} if /^$req\s*$end$/;
    }
    if (/^$req\s*(de\S*|am\S*|ig)\s*(.*)/) {
      my ($f, $l) = ($1, $2);
      push @{$self->end}, "\\.";
      my @list = split /\s+/, $l;
      shift @list if $f =~ /^(de|am)/;
      if (defined $list[-1]) {
        my $end = join '', map { s/[\\.'"\[\](){}]/\\$&/; $_ } split //, $list[-1];
        push @{$self->end}, "(?:" . join('|', pop(@{$self->end}), $end) . ")";
      }
    } else {
      $self->prepro;
    }
    $self->puts;

    return 1 unless @{$self->unget};
  }

  undef;
}


sub prepro {
  my ($self) = @_;
}


sub pua_char {
  my ($self, $token, $cs) = @_;
  if (ref $cs eq 'CODE') {
    my @cf = split /\s+/, &$cs;
    my $cs = join ':', @cf;
    unless ($self->pua->{$cs}) {
      my ($free, $end) = map hex($_), @cf;
      $self->pua->{$cs} = { free => $free, start => $free, end => $end };
    }
    $token =~ s{\p{InPUA}}{$self->pua->{$&}}eg;

    # escape [.'] with \& to prevent $token at the begining of line
    # become control line
    my $req = $self->re_req;
    $token =~ s{^$req}{\\&$&};
    unless (defined $self->pua->{token}{$token}) {
      if ($self->pua->{$cs}{free} > $self->pua->{$cs}{end}) {
        die "can't allocate pua($token, ",
          sprintf("%X..%X", $self->pua->{$cs}{start}, $self->pua->{$cs}{end}),
          "); try to run with pua_saving => 1\n";
      }
      my $code = pack "U", $self->pua->{$cs}{free}++;
      if ($self->debug & 16) {
        say STDERR "# _roffchar: \$token = $token, \$cs = $cs, \$code = ",
          sprintf("\\x{%X}", ord $code);
      }
      $self->pua->{$code} = $token;
      $self->pua->{token}{$token} = $code;
    }
    $self->pua->{token}{$token};
  } else {
    my $code = $cs;
    unless (defined $token) {
      if ($self->debug & 16) {
        my ($pname, $fname, $line) = caller;
        say STDERR "# pua_char: \$token = undef, \$cs = ",
          sprintf("'\\x{%X}'", ord($cs)),
          " called from near $fname($line)";
      }
      $token = '';
    }
    $self->pua->{$code} = $token;
    $self->pua->{token}{$token} = $code;
  }
}


sub pua_stats {
  my ($self) = @_;

  my %used;
  for (keys %{$self->pua}) {
    next unless ref $self->pua->{$_};
    next unless exists $self->pua->{$_}{free};
    $used{$self->pua->{$_}{start}} = {
      a => $self->pua->{$_}{free} - $self->pua->{$_}{start},
      b => $self->pua->{$_}{end} - $self->pua->{$_}{start},
    };
  }
  say STDERR '# pua stats: ', join ', ', map { sprintf("%X: %s", $_, "$used{$_}{a}/$used{$_}{b}") } sort keys %used;
}


sub puts {
  my $self = shift;
  if (@_) {
    $self->puts() for @_;
  } else {
    my @lines = split /\n/;
    @lines = "" unless @lines;
    for (@lines) {
      s{\p{InPUA}}{
        my $subst = $self->pua->{$&};
        $subst .= ".lf $.\n" if $subst =~ /\n$/;
        $subst;
      }eg;
      $self->putline;
    }
  }
}


sub putline {
  my ($self) = @_;
  say;
}


sub gets {
  my ($self) = @_;

  my $req = $self->re_req;
  my $er = $self->_er;
  my $ec = $self->_ec;

  return undef unless defined $self->getline();

  my ($last_req, $last_er, $last_ec) =
    (scalar(/^$req/), scalar(/$er$/), scalar(/$ec$/));
  while ($last_er || !$last_req && $last_ec) {
    my $line = $_;
    if (defined $self->getline()) {
      my ($is_req, $is_er, $is_ec) =
        (scalar(/^$req/), scalar(/$er$/), scalar(/$ec$/));
      if (!$last_er && !$last_req && $last_ec && $is_req) {
        unshift @{$self->unget}, $_;
        $_ = $line;
        last;
      }
      $_ = $line . "\n" . $_;
      ($last_req, $last_er, $last_ec) =
        ($is_req, $is_er, $is_ec);
    } else {
      $_ = $line;
      last;
    }
  }

  $. = $1 - 1 if /^$req\s*lf\s+(\d+)/;

  return $_;
}


sub getline {
  my ($self) = @_;

  my $esc = $self->re_esc;

  if (defined ($_ = shift @{$self->unget})) {
    ;
  } elsif (defined ($_ = <>)) {
    my $newline = chomp;
    1 while s{$esc}{$self->pua_char($&, \&InESC)}e;
    $_ .= $self->_ec unless $newline;
  }
  $_;
}

1;
__END__

=encoding utf-8

=head1 NAME

App::grops::prepro - groff grops prepro

=head1 SYNOPSIS

    use App::grops::prepro;
    exit(App::grops::prepro->run);

=head1 DESCRIPTION

App::grops::prepro is the base module of prepro described in DESC of
grops and gropdf.

Passes processing to the language-dependent perl module when -mI<lang>
is specified on the groff command line.

=head1 LICENSE

Copyright (C) KUBO, Koichi.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

KUBO, Koichi E<lt>k@obuk.orgE<gt>

=cut


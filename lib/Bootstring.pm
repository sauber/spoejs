# $Id: Bootstring.pm,v 1.8 2004/06/01 07:32:17 sauber Exp $
# Encode and decode utf8 into a set of basic code points

package Bootstring;

use strict;
use integer;
use utf8;

# $Id: Bootstring.pm,v 1.8 2004/06/01 07:32:17 sauber Exp $
$Bootstring::VERSION = $Bootstring::VERSION = '$Revision: 1.8 $';

# Constructor
#
sub new {
  my $invocant  = shift;
  my $class     = ref($invocant) || $invocant;
  my $self = { @_ };
  bless $self, $class;
  $self->_initialize();
  return $self;
}

# Initializer
#
# This load the basic code points table and set constants for encoding
# and decoding.
# Note: Are these constants reasonable?
#
sub _initialize {
  my $self  = shift;

  # Read parameters from new();
  %{$self} = ( %{$self}, @_ );

  # BASE is number of basic code points
  $self->{BASE} = scalar @{$self->{BASIC}};

  # Defaults
  $self->{DELIMITER} ||= '-';
  $self->{TMIN} ||= 1;
  $self->{TMAX} ||= $self->{BASE} - 1;
  $self->{INITIAL_N} = $self->{BASE} + 1;
  $self->{INITIAL_BIAS} ||= 72;
  $self->{SKEW} ||= 38;
  $self->{DAMP} ||= 700;

  # Render a modification of ascii table
  $self->newtable();
}

# Handle errors
#
sub _croak { require Carp; Carp::croak(@_); }

# Create a variation of the ascii table (or part of it or beyond)
# where all basic code points are first.
#
sub newtable {
  my $self = shift;

  my $n = 0;

  # Put basic code points in beginning of table
  for ( @{$self->{BASIC}} ) {
    $self->{ord}{$_} = $n;
    $n++;
    $self->{maxord} = ord if not exists $self->{maxord} or $self->{maxord} < ord;
  }

  # Put skipped chars after basic code points
  for ( 0..$self->{maxord} ) {
    my $c = chr $_;
    unless ( exists $self->{ord}{$c} ) {
      $self->{ord}{$c} = $n;
      $n++;
    } else {
    }
  }

  # Create a reverse map
  %{$self->{chr}} = reverse %{$self->{ord}};
}

# Input int output char using modified table
#
sub nchr {
  my($self,$c) = @_;

  #return $_[0] > $self->{maxord} ? chr($_[0]) : $self->{chr}{$_[0]} ;
  return $c > $self->{maxord} ? chr($c) : $self->{chr}{$c} ;
}
 
# Input char output char using modified table
#
sub nord {
  my($self,$c) = @_;

  return exists $self->{ord}{$c} ? $self->{ord}{$c} : ord($c) ;
}

# Hex code of ascii/utf8 char
#
sub hex4 {
  return sprintf('%04x', ord(shift));
}

# Dump modified table, for testing
#
sub dumptable {
  my $self = shift;

  for (0..$self->{maxord}) {
    printf "%d = %s\n", $_, $self->nchr($_);
  }
}

# The bootstring adaption algorithm
#
sub adapt {
  my($self,$delta, $numpoints, $firsttime) = @_;

  $delta = $firsttime
         ? $delta / $self->{DAMP}
         : $delta / 2;
  $delta += $delta / $numpoints;
  my $k = 0;
  while ( $delta > (($self->{BASE}-$self->{TMIN})*$self->{TMAX})/2 ) {
    $delta /= $self->{BASE} - $self->{TMIN};
    $k += $self->{BASE};
  }
  return $k + ( (($self->{BASE}-$self->{TMIN}+1) * $delta)
                / ($delta+$self->{SKEW}) );
}

# Encoding routine
#
sub encode {
  my $self = shift;
  my $input = shift;

  if ( exists $self->{DEBUG} ) {
    $self->{trace} = "Encoding trace of $input:\n\n";
  }

  #my @input = split //, $input; # doesn't work in 5.6.x!
  my @input = map substr($input, $_, 1), 0..length($input)-1;

  my $n     = $self->{INITIAL_N};
  my $delta = 0;
  my $bias  = $self->{INITIAL_BIAS};
  my $BasicRE = join'',@{$self->{BASIC}};
  $BasicRE = qr/[$BasicRE]/;

  # Trace output
  if ( exists $self->{DEBUG} ) {
    $self->{trace} .= "bias is $bias\n"
                   .  "input is:\n"
                   .  join(' ', map hex4($_), @input) . "\n";
  }

  my @output;
  my @tmpout;
  my @basic = grep /$BasicRE/, @input;
  my $h = my $b = @basic;
  push @output, @basic, $self->{DELIMITER} if $b > 0;

  if ( exists $self->{DEBUG} ) {
    if ( @basic ) {
      $self->{trace} .= 'basic code points ('
                     .  join(', ', map hex4($_), @basic)
                     .  ') are copied to literal portion: "'
                     .  join('', @output)
                     .  '"' . "\n";
    } else {
      $self->{trace} .= "there are no basic code points, so no literal portion\n";
    }
  }

  while ($h < @input) {
    my $m = min(grep { $_ >= $n } map $self->nord($_), @input);
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= sprintf "next code point to insert is %04x\n", $m;
    }
    $delta += ($m - $n) * ($h + 1);
    $n = $m;
    for my $i (@input) {
      my $c = $self->nord($i);
      $delta++ if $c < $n;
      if ($c == $n) {
        my $q = $delta;
      LOOP:
        for (my $k = $self->{BASE}; 1; $k += $self->{BASE}) {
          my $t = ($k <= $bias) ? $self->{TMIN} :
            ($k >= $bias + $self->{TMAX}) ? $self->{TMAX} : $k - $bias;
          last LOOP if $q < $t;
          my $cp = $self->nchr($t + (($q - $t) % ($self->{BASE} - $t)));
          push @tmpout, $cp;
          $q = ($q - $t) / ($self->{BASE} - $t);
        }
        push @tmpout, $self->nchr($q);
        $bias = $self->adapt($delta, $h + 1, $h == $b);
        $delta = 0;
        $h++;
      }
    }
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= "needed delta is $delta, encodes as " . '"'
                     .  join('',@tmpout) . '"' . "\n"
                     .  "bias becomes $bias\n";
    }
    push @output, @tmpout;
    @tmpout = ();
    $delta++;
    $n++;
  }
  if ( exists $self->{DEBUG} ) {
    $self->{trace} .= 'output is "' . join('', @output) . '"' . "\n";
  }
  return join '', @output;
}

# Find minimum value in list
#
sub min {
  my $min = shift;
  for (@_) { $min = $_ if $_ <= $min }
  return $min;
}

# Bootstring decoding routing
#
sub decode{
  my $self = shift;
  my $code = shift;

  if ( exists $self->{DEBUG} ) {
    $self->{trace} = "Decoding trace of $code:\n\n";
  }

  my $n      = $self->{INITIAL_N};
  my $i      = 0;
  my $bias   = $self->{INITIAL_BIAS};
  my $BasicRE = join'',@{$self->{BASIC}};
  #$BasicRE = qr/[$BasicRE]/;
  #$BasicRE = qr/[join'',@{$self->{BASIC}}]/;

  my @output;

  if ( exists $self->{DEBUG} ) {
    $self->{trace} .= "n is $n, i is $i, bias = $bias\n"
                   .  'input is "' . $code . '"' . "\n";
  }

  if ($code =~ s/(.*)$self->{DELIMITER}//o) {
    push @output, map $self->nord($_), split //, $1;
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= 'literal portion is "' . $1 . $self->{DELIMITER}
                     .  '", so extended string starts as:' . "\n"
                     .  join(' ', map hex4($self->nchr($_)), @output) . "\n";
    }
    my $bas = join('',@{$self->{BASIC}});
    for ( split //, $1 ) {
      return _croak('non-basic code point' ) unless $bas =~ /$_/o;
    }
  } else {
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .=
           "there is no delimiter, so extended string starts empty\n";
    }
  }

  while ($code) {
    my $oldi = $i;
    my $w    = 1;
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= 'delta "';
    }
  LOOP:
    for (my $k = $self->{BASE}; 1; $k += $self->{BASE}) {
      my $cp = substr($code, 0, 1, '');
      my $digit = $self->nord($cp);
      if ( exists $self->{DEBUG} ) {
        $self->{trace} .= $cp;
      }
      defined $digit or return _croak("invalid punycode input");
      $i += $digit * $w;
        my $t = ($k <= $bias)
                ? $self->{TMIN}
                : ($k >= $bias + $self->{TMAX})
                  ? $self->{TMAX}
                  : $k - $bias;
        last LOOP if $digit < $t;
        $w *= ($self->{BASE} - $t);
    }
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= '" decodes to ' . "$i\n";
    }
    $bias = $self->adapt($i - $oldi, @output + 1, $oldi == 0);
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= "bias becomes $bias\n";
    }
    $n += $i / (@output + 1);
    $i = $i % (@output + 1);
    splice(@output, $i, 0, $n);
    if ( exists $self->{DEBUG} ) {
      $self->{trace} .= join(' ', map hex4($self->nchr($_)), @output) . "\n";
    }
    $i++;
  }
  my $res = pack("C*", map ord $self->nchr($_), @output);
  return $res;
}

__END__;

=head1 NAME

Bootstring - Encode a large symbol set into a small symbol set

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

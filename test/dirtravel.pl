#!/usr/bin/perl -w -I../lib

# Start at any story, and go through dirs to find newer and older
# stories, and then order by date-dir.
#
# $Id: dirtravel.pl,v 1.1 2004/06/23 03:33:52 sauber Exp $

use Spoejs;
use Spoejs::Story;
use Spoejs::Lang;
use Date::Manip;
use strict;

my $srcdir = '/www/spoejs/htdocs/users/life';
my $L = new Spoejs::Lang( lang_order => [ 'en' ] );
my %SL = ();  # Read stories indexed by dir
my $first;
my $last;

# Read in a single story, and index it by it's index
# Generate a sortkey for the story
#
sub read_story {
  my($index) = @_;

  warn "  ( Reading story $index ... )\n";
  my $story = new Spoejs::Story ( path => "$srcdir/$index", lang => $L );
  warn $story->{msg} if $story->{msg};
  my $sortkey = ParseDate( $story->get('date') ) . "-$index";
  $SL{$index}{sortkey} = $sortkey;
  $SL{$index}{story} = $story;
}

# Search for more dirs to expand list of stories from
#
sub more_dirs {
  my($index,$grow) = @_;

  # Are we looking for next or prev dirs?
  # Prepare a comparison for eval later
  my($cmp,$x);
  if ( $grow eq 'next' ) {
    $cmp = '$_ > $x';
  } elsif ( $grow eq 'prev' ) {
    $cmp = '$_ < $x';
  } else {
    warn "No direction specified\n";
    return;
  }

  # Search starts from year, month, counter
  my ($y,$m,$c) = $index =~ m~(\d\d\d\d)/(\d\d)/(\d\d)~;
  
  # Below, when sorting months and years, find first or last entry?
  my $z = $grow eq 'next' ? 0 : -1 ;

  # The goal is to find out which nextmonth to read from
  my($nextmonth);

  # Find the next/prev month within same year, if possible
  opendir DH, "$srcdir/$y";
    $x = $m; # For use in $cmp
    ($nextmonth) = map { "$y/$_" }
                   ( sort
                     grep { eval $cmp } grep /^..$/, grep !/^\./,
                     readdir DH
                   )[$z];
  closedir DH;

  # Do we have to read first/last month of next/prev year, instead?
  unless ( $nextmonth ) {
    opendir DH, "$srcdir";
      $x = $y; # For use in $cmp
      my $nextyear = ( sort
                       grep { eval $cmp } grep /^\d\d\d\d$/, grep !/^\./,
                       readdir DH
                     )[$z];
    closedir DH;

    # Stop if nothing could be found
    unless ( $nextyear ) {
      warn "Warning: No more dirs available\n";
      return;
    }

    opendir DH, "$srcdir/$nextyear";
      $x = $grow eq 'next' ? '00' : '13' ; # For use in $cmp
      ($nextmonth) = map { "$nextyear/$_" }
                     ( sort
                       grep { eval $cmp } grep /^..$/, grep !/^\./,
                       readdir DH
                     )[$z];
    closedir DH;
  }

  my $thismonth = "$y/$m";

  # Read all new dirs in $thismonth + $nextmonth
  my(@dirs);
  for my $ym ( $thismonth, $nextmonth ) {
    opendir DH, "$srcdir/$ym";
      push @dirs, map { "$ym/$_"}
                  grep { !exists $SL{"$ym/$_"} }
                  grep /^..$/, grep !/^\./,
                  readdir DH;
    closedir DH;
  }

  for my $dir ( @dirs ) {
    read_story($dir);
  }
}

# Sort all stories by date-dir
#
sub order_stories {
  # First remove old chain
  for my $k ( keys %SL ) {
    delete $SL{$k}{prev} if exists $SL{$k}{prev};
    delete $SL{$k}{next} if exists $SL{$k}{next};
    delete $SL{$k}{last} if exists $SL{$k}{last};
    delete $SL{$k}{first} if exists $SL{$k}{first};
  }

  # Generate new sorted list and set up chain
  my @sorted = sort { $SL{$a}{sortkey} cmp $SL{$b}{sortkey} } keys %SL;
  if ( @sorted == 0 ) {
    return;
  } elsif ( @sorted == 1 ) {
    $first = $last = $sorted[0];
  } elsif ( @sorted == 2 ) {
    ($first,$last) = @sorted;
    $SL{$first}{next} = $SL{$last};
    $SL{$last}{prev} = $SL{$first};
  } elsif ( @sorted > 2 ) {
    $first = $sorted[0];
    $last = $sorted[-1];
    $SL{$first}{next} = $SL{$sorted[1]};
    $SL{$last}{prev} = $SL{$sorted[-2]};
    for my $p ( 1 .. $#sorted-1 ) {
      $SL{$sorted[$p]}{prev} = $SL{$sorted[$p-1]};
      $SL{$sorted[$p]}{next} = $SL{$sorted[$p+1]};
    }
  }
  $SL{$first}{first} = 1;
  $SL{$last}{last} = 1;
}

# Dump the chains
#
sub dump_story_chain {
  print "Forwards...\n";
  my $cur = $SL{$first};
  print "first -> $cur\n";
  while ( exists $cur->{next} ) {
    print "$cur -> $cur->{next}\n";
    $cur = $cur->{next};
  }
  print "$cur -> last\n";

  print "Backwards...\n";
  $cur = $SL{$last};
  print "last -> $cur\n";
  while ( exists $cur->{prev} ) {
    print "$cur -> $cur->{prev}\n";
    $cur = $cur->{prev};
  }
  print "$cur -> first\n";
}

# Find index of story +/- N steps away
# Read in additional stories as they become necessary
sub story_step {
  my($index,$count) = @_;

  # Going forwards or backwards?
  my($f,$x);
  if ( $count >= 1) {
    $f = 1; $x = 'next';
  } elsif ( $count <= -1 ) {
    $f = -1; $x = 'prev';
  } else {
    warn "Warning: Invalid count\n";
    return;
  }

  read_story($index) unless exists $SL{$index};
    
  my $cur = $SL{$index};
  print "Starting at " . $cur->{story}->story_path_from_full() . "\n";
  for my $i ( 1 .. abs($count) ) {
    unless ( exists $cur->{$x} ) {
      more_dirs( $cur->{story}->story_path_from_full(), $x );
      order_stories();
      return unless exists $cur->{$x};
    }
    $cur = $cur->{$x};
    print " step $i: " . $cur->{story}->story_path_from_full() . "\n";
  }
}

#################### Main stuff ####################

story_step('2004/01/02',10);
story_step('2004/01/02',-10);

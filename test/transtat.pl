#!/usr/bin/perl -w -I../lib

# Generate statistics for how much as been translated.
# $Id: transtat.pl,v 1.1 2004/08/11 13:11:13 sauber Exp $

use Spoejs::Resource;
my $dir = $ENV{SPOEJS_PATH} || '.';
my $R = new Spoejs::Resource( path=>$dir );
die $R->{msg} if $R->{msg};

# Get list of keys for words to translate
my @keys = $R->keys;

# Count how many translations total
for $k ( @keys ) {
  for $l ( keys %{$R->{data}{$k}} ) {
    $L{$l}++;
  }
}

# Print statistics for each language
for ( sort keys %L ) {
  $f = int 100 * $L{$_} / @keys;
  $t += $f;
  printf "% 12s:% 4d%1s complete\n", $R->{data}{$_}{en}, $f, '%';
  $i++;
}

# Totals
$t = int $t / $i;
print "\n";
printf "% 12s:% 4d%1s complete\n", 'Total', $t, '%';

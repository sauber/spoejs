#!/usr/bin/perl -w -I../lib

use Spoejs::Stats;

my $path = '/www/spoejs/htdocs/users/soren/2004/04/01';
my $img = 'IMG5618_Zn.jpg';
my $S = new Spoejs::Stats( path => $path );

$S->access($img) or print "Error: $S->{msg}\n";
my($t,$m,$w) = $S->stats($img);
print "Error: $S->{msg}\n" unless $t;
print "Total for $img: $t\n";
print "Month for $img: $m\n";
print "Week  for $img: $w\n";

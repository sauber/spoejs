#!/usr/bin/perl -w -I../lib

# generates and icon file in jpg format by using Spoejs::Icon

# $Id: icon.pl,v 1.2 2004/03/04 07:23:36 sauber Exp $

use Spoejs::Icon;

my $I = Spoejs::Icon->new();

die "No category specified" unless $ARGV[0];

my $category = $ARGV[0];

$iconref = $I->get(category=>$category, size=>75);

if ( $iconref ) {
  open FH, ">$category.jpg";
    print FH $$iconref;
  close FH;
} else {
  die "No icon for $category could be rendered";
}

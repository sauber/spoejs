#!/usr/bin/perl -w -I../lib

use Spoejs::StoryList;
use Spoejs::Lang;
use Data::Dumper;

my $L = Spoejs::Lang->new( lang_order => ['en'] );

my $path = '/usr/local/wwwdoc/spoejs/htdocs/users/test/';
my $SL = Spoejs::StoryList->new( path => $path, lang => $L );

my $dir = $SL->add_story();

$SL->del_story( story => $dir );

my @all_stories = $SL->list_stories();
print "All stories:\n";
print $_->get( 'date' ), "\n" for @all_stories;

@count_stories = $SL->list_stories( count => 3 );
print "'count' stories:\n";
print $_->get( 'date' ), "\n" for @count_stories;

my @cat_stories = $SL->list_stories( category => 'sport' );
print "'category' stories:\n";
print $_->get( 'date' ), "\n" for @cat_stories;

my @range_stories = $SL->list_stories( from=>'2004/02/04', to=>'2004/02/08' );
print "range stories:\n";
print $_->get( 'date' ), "\n" for @range_stories;

my @prev_stories = $SL->list_stories( story=>'2004/02/04', prev => 3 );
print "prev stories:\n";
print $_->get( 'date' ), "\n" for @prev_stories;

my @next_stories = $SL->list_stories( story=>'2004/02/04', next => 1 );
print "next stories:\n";
print $_->get( 'date' ), "\n" for @next_stories;

my %counts = $SL->count_stories( by => 'category' );
print "Counts:\n";
print Dumper( %counts );


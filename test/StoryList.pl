#!/usr/bin/perl -w -I../lib

use Spoejs::StoryList;
use Spoejs::Lang;

my $L = Spoejs::Lang->new( 'en' );

my $SL = Spoejs::StoryList->new( lang => $L );

my $dir = $SL->add_story();

$SL->del_story( story => $dir );

my @sorted_stories = $SL->list_stories();

print $_->date(), "\n" for @sorted_stories;

#!/usr/bin/perl -w -I../lib

use Spoejs;
use Spoejs::StoryList;
use Spoejs::Media;
use Spoejs::Lang;
use Spoejs::Pic;
use Spoejs::Archive;
use Spoejs::Movie;
use Data::Dumper;

my $L = Spoejs::Lang->new( lang_order => ['en'] );

my $path = $ARGV[0] || '../htdocs/users/life';
my $SL = Spoejs::StoryList->new( path => $path, lang => $L );

my @all_stories = $SL->list_stories();
print "All stories in $path:\n";
print "Path\tDate\tTitle\tRandom Media\n";

for ( @all_stories ) {
  # See if there are any media files
  my $pic = $$_{ML}->get('always_random');
  my $med = defined $pic ?  $pic->{file} : '' ;

  printf "%s\t%s\t%s\t%s\n",
  $$_{path},
  $_->get( 'date' ),
  $_->get( 'title' ),
  $med;
}



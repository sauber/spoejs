#!/usr/bin/perl -w -I../lib

use Spoejs::Lang;
use Spoejs::Syndication;
use Spoejs::StoryList;
use XML::RSS;

my $path = $ARGV[0] || '../htdocs/users';
die "Error: $path doesn't exists" unless -d $path;

my $L = Spoejs::Lang->new( lang_order => ['en'] );
my $SYN = new Spoejs::Syndication( path=>$path, lang=>$L );
my @sns = $SYN->local_channel_newestdate_list();

for my $c ( @sns ) {
  printf "Channel shortname: %s\n", $c->{shortname};
  printf "Channel date     : %s\n", $c->{date};
}

## Create a rss object with the channel information
#my $rss = new XML::RSS( version => '2.0' );
#$rss->channel(
#  title => "Spoejs",
#  link => $ENV{SERVER_NAME},
#  description => "Spoejs is basically fun",
#  dc => {
#  },
#);


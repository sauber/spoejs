#!/usr/bin/perl -w -I../lib

use Spoejs::ChannelList;
use Data::Dumper;

my $CL = new Spoejs::ChannelList( path => '../htdocs/users/' );

my @channels = $CL->search_channels( username => 'snicki',
				     password => 'kodeord');

print Dumper( @channels );

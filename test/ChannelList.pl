#!/usr/bin/perl -w -I../lib

use Spoejs::ChannelList;
use Data::Dumper;

my $CL = new Spoejs::ChannelList( path => '../htdocs/users/' );

my $res = $CL->new_channel( username => 'snicki', password => 'kodeord',
			    title=>'Test channel', shortname => 'testchan',
			    description => 'This is just a test channel' );

die $CL->{msg} unless $res;

my @channels = $CL->search_channels( username => 'snicki',
				     password => 'kodeord');

print Dumper( @channels );

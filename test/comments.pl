#!/usr/bin/perl -w -I../lib

#use Spoejs::Comments;
use YAML;

#my $path = '/tmp';
#my $CM = new Spoejs::Comments( path => $path );

my %c = ( Name => 'Soren Syvsover',
          Date => 1027603280,
          Email => 'test@test',
          Comment => 'What more can I say... Amiga rulez, the party (1998) was a hell lot of fun and an exerience I will never forget. :)'
        );

push @{$com{'story'}}, \%c;
%d = %c; $d{Date}++;
push @{$com{'story'}}, \%d;
%e = %c; $e{Date}+=2;
push @{$com{'pic01_.jpg'}}, \%e;

print Dump(\%com);

#!/usr/bin/perl -w -I../lib

use Spoejs::Lang;
use Data::Dumper;

my $cookie_lang = 'de';
my @browser_langs = qw( en dk );
my $channel_lang = 'dk';


my $L = new Spoejs::Lang( $cookie_lang, @browser_langs, $channel_lang );


my $category = $L->tr( { en=>'handball', dk=>'haandbold' } );
print $category . "\n";

my %D = $L->tr( { abstract=>{ en=>'something about'},
		  category=>{ en=>'handball', dk=>'haandbold' } 
	      } );

print Dumper(%D);

#!/usr/bin/perl -w -I../lib

use Spoejs::Lang;
use Data::Dumper;

my $cookie_lang = 'de';
my @browser_langs = qw( en dk );
my $channel_lang = 'dk';


my $L = new Spoejs::Lang( $cookie_lang, @browser_langs, $channel_lang );


my $category = $L->tr( { en=>'handball', dk=>'haandbold' } );
print "Category: " . $category . "\n";

my %D = $L->tr( { abstract => 'something about',
		  category => 'handball' 
	      } );

print "Dumping %D;\n" . Dumper(\%D);

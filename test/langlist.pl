#!/usr/bin/perl -w -I../lib

# Print out all languages present in resource.txt

use Spoejs::Resource;

my $R = Spoejs::Resource->new(path=>'../lib');

print join ' ', $R->lang_list();
print "\n";

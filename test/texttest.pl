#!/usr/bin/perl -w -I../lib

use Data::Dumper;
use Spoejs::Text;
use Spoejs::Lang;

%data = 
   ( title => { dk => "Haandbold",
   	       en => "Handbold" },
     date => { en => "Feb 01 2004 00:43" },
     abstract => { en => "Something about handball",
   	          dk => "Noget om haandbold" },
     category => { dk => "sport" },
     annotations => { en => "pic1.jpg: The game starts\npic25.jpg: The game is over",
                      dk => "pic1.jpg: Kampen starter\npic20.jpg: Bolden går ind" },
     fulltext => { dk => "Ej for en lang kamp.\n\nDen var godt nok spændende. Den må vi se igen en anden gang." }
   );

# Create Lang for prefered translation
my $L = new Spoejs::Lang( 'dk' );

# Create new story (or read existing)
$T = Spoejs::Text->new( path => "/usr/local/wwwdoc/spoejs/test",  
			file => "report.txt", lang => $L );

# Set some contents
$T->set( %data ); 

# Change contents
$T->set( abstract => { en => "Something funny about handball" } );

# Add single entry
#$T->set( single_test => "value" );

# Get something back
%data1 = $T->get( "abstract", "date" );

$T->set( abstract => { en => undef } );
$T->set( abstract => { en => "Something less funny about handball" } );
%data2 = $T->get();

# Print it
print "\nDumping %data:\n";
print "subset: \n" . Dumper(%data1);
print "\n\nfull: \n" . Dumper(%data2);

# Cleanup
$T->del();

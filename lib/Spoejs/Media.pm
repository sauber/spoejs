# Todo:
# Read/write files
# Perhaps file size check

package Spoejs::Media;
no Carp::Assert;
use base ( "Spoejs" );

# $Id: Media.pm,v 1.1 2004/02/27 07:45:24 sauber Exp $
$Spoejs::Text::VERSION = $Spoejs::Text::VERSION = '$Revision: 1.1 $';


#### Private helper functions ####

# strip illegal chars from filename
#
my $valid_name = sub {
    my($self,$f) = @_;

    $f =~ tr/A-Z/a-z/;                        # Only lowercase letters
    $f =~ s/[^a-z0-9.]//g;                  # Only letters and numbers
    while ( $f =~ s/(.*)\.(.*)\.(.+?)/$1$2\.$3/g ) {}   # Only one dot
    return $f;
};

#### Public interface ####

1;

package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.1 2004/03/02 04:14:11 snicki Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.1 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, 
		      full_path => "$ENV{DOCUMENT_ROOT}/../lib/resource.txt" );
    # Read in resource file
    $self->get();
}

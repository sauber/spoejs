package Spoejs::Story;
use base ( "Spoejs", "Spoejs::Text" );

# $Id: Story.pm,v 1.1 2004/02/26 05:46:06 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.1 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'data.txt' );
}

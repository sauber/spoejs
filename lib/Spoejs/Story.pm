package Spoejs::Story;
use base ( "Spoejs", "Spoejs::Text" );

# $Id: Story.pm,v 1.3 2004/02/28 07:35:24 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.3 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'data.txt' );
}

# Return a story's date
# XXX: Add set functionality
#
sub date {
    my $self = shift;
    
    return $self->get( "date" );
}

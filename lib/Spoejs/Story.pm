package Spoejs::Story;
use base ( "Spoejs::Text" );

# $Id: Story.pm,v 1.4 2004/02/29 00:00:34 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.4 $';

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

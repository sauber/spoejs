package Spoejs::Story;
use base ( "Spoejs", "Spoejs::Text" );

# $Id: Story.pm,v 1.2 2004/02/27 06:55:35 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'data.txt' );
}

# Return a story's date
# XXX: Add set functionality
#
sub date {
    my $self = shift;
    
    my %date = $self->get( "date" );

    return $date{date};
}

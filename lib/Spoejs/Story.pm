package Spoejs::Story;
use base ( "Spoejs::Text" );

# $Id: Story.pm,v 1.5 2004/03/04 11:43:52 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.5 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_, file => 'data.txt' );
}

# Return a story's date
# XXX: Add set functionality
#
sub date {
    my $self = shift;
    
    return $self->get( "date" );
}

# Extract the story-path portion af the full path.
# XXX: Is trailing /'es a problem?
sub story_path_from_full {
    my $self = shift;

    my @parts = split /\//, $self->{path};
    @parts = reverse @parts;
    my $story_path = "$parts[2]/$parts[1]/$parts[0]";

    return $story_path;
}

package Spoejs::Story;
use base ( "Spoejs::Text" );
use Spoejs::MediaList;

# $Id: Story.pm,v 1.6 2004/03/22 07:09:00 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.6 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_, file => 'data.txt' );
    $self->{ML} = new Spoejs::MediaList( path => $self->{path} );
}

# Return a story's date
# XXX: Add set functionality
#
sub date {
    my $self = shift;
    
    return $self->get( "date" );
}

# Extract the story-path portion af the full path.
sub story_path_from_full {
    my $self = shift;

    my @parts = split /\//, $self->{path};
    @parts = reverse @parts;
    my $story_path = "$parts[2]/$parts[1]/$parts[0]";

    return $story_path;
}
 
sub story_string_from_full {
    my $self = shift;

    my $story_string = $self->story_path_from_full();
    $story_string =~ s{/}{}g;

    return $story_string;
}
 

sub media_list {
    my $self = shift;

    return $self->{ML}->list();
}

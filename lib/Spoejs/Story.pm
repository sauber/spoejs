package Spoejs::Story;
use base ( "Spoejs::Text" );
use Spoejs::MediaList;

# $Id: Story.pm,v 1.7 2004/03/29 04:25:20 snicki Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.7 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_, file => 'data.txt' );
    return $self->_err( "Missing or invalid path: $self->{path}" )
	unless $self->{path};
    $self->{ML} = new Spoejs::MediaList( path => $self->{path} );
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

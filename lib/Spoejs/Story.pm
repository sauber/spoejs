package Spoejs::Story;
use base ( "Spoejs::Text" );
use Spoejs::MediaList;

# $Id: Story.pm,v 1.8 2004/04/09 17:18:39 sauber Exp $
$Spoejs::Story::VERSION = $Spoejs::Story::VERSION = '$Revision: 1.8 $';

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

__END__
                                                                                
=head1 NAME
                                                                                
Spoejs::Story - Text, Attributes, MediaList, Annotations, Comments for a story

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

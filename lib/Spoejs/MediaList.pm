package Spoejs::MediaList;
use base ( "Spoejs::List" );

# $Id: MediaList.pm,v 1.2 2004/03/22 12:19:37 snicki Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.2 $';

# Should be called with 'path' to directory containing the media
sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_ );
}

#### Private helper functions ####

sub _next {
    my ( $self, $current, @media ) = @_;
    $current =~ s{(.*)(...)}{$1\.$2}g;
    my $found;
    for ( @media ) {
	if ($found) { $found = $_->{path}; last; }
	$found = 1 if ( $_->{path} =~ /$current/ );
    }

    return undef if $found == 1;

    my @p = reverse split /\//, $found;
    $found = $p[0];
    $found =~ s{\.}{}g;
    return $found;
}





#### Public interface ####

sub list {
    my $self = shift;

    my @files = $self->_list_from_file_pattern( '(jpg|JPG)$' );
    my @items;

    for ( sort @files ) {
	push @items, new Spoejs::Pic( path => $_ );
    }

    return @items;
}


sub next {
    my ( $self, $current ) = @_;

    return $self->_next( $current, $self->list() );
}


sub prev {
    my ( $self, $current ) = @_;

    return $self->_next( $current, reverse $self->list() );
}

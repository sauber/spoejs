package Spoejs::MediaList;
use base ( "Spoejs::List" );
use File::Basename;

# $Id: MediaList.pm,v 1.4 2004/03/25 03:48:48 snicki Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.4 $';

# Should be called with 'path' to directory containing the media
sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_ );
}

#### Private helper functions ####

sub _next {
    my ( $self, $current, @media ) = @_;
    my $found;
    for ( @media ) {
	if ($found) { $found = $_->{file}; last; }
	$found = 1 if ( $_->{file} =~ /$current/ );
    }

    return undef if $found == 1;
    return basename $found;
}


#### Public interface ####

sub list {
    my $self = shift;

# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '(jpg|JPG)$' );
    my @items;

    for ( sort @files ) {
	@d{ 'file', 'path' } = fileparse $_;
	push @items, new Spoejs::Pic( %d );
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

sub get_picref {
    my ( $self, $current ) = @_;
    
    my @all = $self->list();

    for ( @all ) {
	return $_ if ( $_->{file} eq $current );
    }

    return undef;
}

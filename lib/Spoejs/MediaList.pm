package Spoejs::MediaList;
use base ( "Spoejs::List" );
use File::Basename;

# $Id: MediaList.pm,v 1.5 2004/03/27 09:32:56 snicki Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.5 $';

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

sub _list {

    my ($self, @files) = @_;


    my @items;

    for ( @files ) {
	@d{ 'file', 'path' } = fileparse $_;
	push @items, new Spoejs::Pic( %d );
    }

    return @items;

}
#### Public interface ####

sub list {
    my $self = shift;
# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '(jpg|JPG)$' );
    return $self->_list( sort @files );
}


sub list_unsorted {
    my $self = shift;
# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '(jpg|JPG)$' );
    return $self->_list( @files );
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


# Get particular media based on keyword: first, last, random
#
sub get {
    my ( $self, $type ) = @_;


    if ( $type eq 'first' ) {
	my @all = $self->list();
	return $all[0];
    } elsif ( $type eq 'last' ) {
	my @all = reverse $self->list_unsorted();
	return $all[0];
    }
    else {
	my $i = int rand($#all + 1);
	return $all[$i];
    }    

}

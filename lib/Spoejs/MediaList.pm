package Spoejs::MediaList;
use base ( "Spoejs::List" );

# $Id: MediaList.pm,v 1.1 2004/03/22 07:09:00 snicki Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.1 $';

# Should be called with 'path' to directory containing the media
sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_ );
}

sub list {
    my $self = shift;

    my @files = $self->_list_from_file_pattern( "jpg|JPG" );
    my @items;

    for ( @files ) {
	push @items, new Spoejs::Pic( path => $_ );
    }

    return @items;
}

package Spoejs::MediaList;
use base ( "Spoejs::List" );
use File::Basename;
use Data::Dumper;

# $Id: MediaList.pm,v 1.9 2004/04/04 04:58:49 snicki Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.9 $';

# Should be called with 'path' to directory containing the media
sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_ );
}

#### Private helper functions ####

sub _next {
    my ( $self, $current, $count, @media ) = @_;
    my $found = undef;
    my @res;
    my $c = 0;
    for ( @media ) {
	$found = 1 if ( $_->{file} =~ /$current/ );
	if ($found) { 
	    push @res, $_;
	    $c++;
	    last if $c >= $count;
	}
    }
    return @res;
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
    my @files = $self->_list_from_file_pattern( '(jpg|JPG|png|PNG)$' );
    return $self->_list( sort @files );
}


sub list_unsorted {
    my $self = shift;
# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '(jpg|JPG|png|PNG)$' );
    return $self->_list( @files );
}



sub next {
    my ( $self, %param ) = @_;
    $param{count} ||= 1;
    my @list = $self->list();
    $param{current} ||= $list[0]->{file};
    return $self->_next( $param{current}, $param{count}, @list );
}


sub prev {
    my ( $self, %param ) = @_;
    $param{count} ||= 1;
    my @list = reverse $self->list();
    $param{current} ||= $list[0]->{file};
    return $self->_next( $param{current}, $param{count}, @list );
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
	my @all = $self->list();
	my $i = int rand($#all + 1);
	return $all[$i];
    }    
}

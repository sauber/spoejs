package Spoejs::MediaList;
use base ( "Spoejs::List" );
use File::Basename;
use Data::Dumper;

# $Id: MediaList.pm,v 1.13 2004/04/09 17:18:39 sauber Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.13 $';

# Should be called with 'path' to directory containing the media
sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_ );
}

#### Private helper functions ####

sub _next {
    my ( $self, $current, $count, @media ) = @_;
    $count ||= 1;
    $current ||= $media[0]->{file};
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

    my ($self, $start, $count, @files) = @_;

    # Remove 'start' elements
    @files = @files[$start..$#files] if $start;

    my @items;
    for ( @files ) {
	@d{ 'file', 'path' } = fileparse $_;
	push @items, new Spoejs::Pic( %d );
    }

    # Shrink array to 'count' elements
    $#items = $count - 1 if $count and @items > $count;

    return @items;
}

#### Public interface ####

sub list {
    my $self = shift;
    my %opt  = @_;
# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '(jpg|JPG|png|PNG|gif|GIF)$' );
    return $self->_list( $opt{start}, $opt{count}, sort @files );
}


sub list_unsorted {
    my $self = shift;
    my %opt  = @_;
# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '(jpg|JPG|png|PNG|gif|GIF)$' );
    return $self->_list( $opt{start}, $opt{count}, @files );
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

__END__

=head1 NAME
                                                                                
Spoejs::MediaList - Manage an album of media

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

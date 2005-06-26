package Spoejs::MediaList;
use base ( "Spoejs::List" );
use File::Basename;
use Data::Dumper;

# $Id: MediaList.pm,v 1.22 2005/06/26 09:27:54 snicki Exp $
$Spoejs::MediaList::VERSION = $Spoejs::MediaList::VERSION = '$Revision: 1.22 $';

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

    # Get index of 'start' if it is a filename
    unless ( $start =~ /^(\d+)$/ ) {
	$start = $self->_index_of( $start, \@files );
    }

    # Remove 'start' elements
    @files = @files[$start..$#files] if $start;

    my @items;
    for ( @files ) {
	@d{ 'file', 'path' } = fileparse $_;
	push @items, new Spoejs::Media( %d );
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
    my @files = $self->_list_from_file_pattern( '('. $self->all_extensions() . ')$' );
    return $self->_list( $opt{start}, $opt{count}, sort @files );
}

sub count {
    my $self = shift;
    my @files = $self->_list_from_file_pattern( '('. $self->all_extensions() . ')$' );
    return scalar @files;
}

sub list_unsorted {
    my $self = shift;
    my %opt  = @_;
# XXX: What pattern should be used here?
    my @files = $self->_list_from_file_pattern( '('. $self->all_extensions() . ')$' );
    return $self->_list( $opt{start}, $opt{count}, @files );
}

sub get_picref {
    my ( $self, @wanted ) = @_;
    
    my @all = $self->list();

    my @res;
    for my $a ( @all ) {
	for my $w ( @wanted ) {
	    push @res, $a if ( $a->{file} eq $w );
	}
    }

    return @res;
}


# Get particular media based on keyword: first, last, random
#
sub get {
    my ( $self, $type ) = @_;

    # XXX: This ads duplicated code, but is fatser than using list();
    my @files = $self->_list_from_file_pattern( '('. $self->all_extensions() . ')$' );
    return undef unless @files > 0;
    my $i;

    if ( $type eq 'first' ) {

	@files = sort @files;
	$i = 0;
    } elsif ( $type eq 'last' ) {
	$i = 0;

    } elsif ( $type eq 'random' or $type eq 'always_random' or $type eq '' ) {

	$i = int rand($#files + 1);
    } else {

	return new Spoejs::Media( path => $self->{path}, file => $type );
    }    

    @d{ 'file', 'path' } = fileparse $files[$i];
    return new Spoejs::Media( %d );
}


# List of extensions for all media types
#
sub all_extensions {
    return $Spoejs::Pic::EXTENSIONS . '|' . $Spoejs::Movie::EXTENSIONS . '|' . 
	$Spoejs::Archive::EXTENSIONS;
}

__END__

=head1 NAME
                                                                                
Spoejs::MediaList - Manage an album of media

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

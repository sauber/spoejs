package Spoejs::List;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: List.pm,v 1.17 2004/10/28 12:07:18 snicki Exp $
$Spoejs::List::VERSION = $Spoejs::List::VERSION = '$Revision: 1.17 $';


# Constructor
# Anticipated params: 
#   'path' - path to dir to work from
#
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );
}

#### Private helper functions ####

# Checks the given path for existence and readability
#
sub _check_dir {
    my $self  = shift;

    $self->{msg} = "Path doesn't exist: $self->{path}"
	unless -d "$self->{path}";
    $self->{msg} = "Can't read path $self->{path}"
	unless -r "$self->{path}";
}

# Give list of dirs in given path
#
sub _dirs_in_path {
    my ( $self, $path ) = @_;

    return $self->_err( "Invalid or missing path: $path") unless $path;

    opendir DH, "$path" or return $self->_err( "Cannot open $path: $!");
    my @res = reverse  sort
                       grep { -d "$path/$_" }
                       grep !/^\./,
                       readdir DH;
    closedir DH;

    return @res;
}


# Make list of directories containing 'file'
#
sub _list_from_filename {

    my ($self, $path, $file ) = @_;

    return $self->_err( "Invalid or missing path: $path") unless $path;
    return $self->_err( "Invalid or missing file: $file") unless $file;

    my @paths;

    use File::Find;
    find ( { wanted => sub {
        my $res = $File::Find::name if /$file$/;
        return unless $res;
        $res =~ s/\/$file//;      #Strip filename
        push @paths, $res;
    }, follow_fast => 1 }, $path);

    return @paths;
}


# List of files matching (in the end) pattern
#
sub _list_from_file_pattern {

    my ($self, $pattern ) = @_;

    return $self->_err( "Invalid or missing path: $self->{path}") 
	unless $self->{path};
    return $self->_err( "Invalid or missing file: $pattern") unless $pattern;

    my @files;

    use File::Find;
    find sub {
	my $res = $File::Find::name if /$pattern$/i;
	push @files, $res if $res;
    },
    $self->{path};

    return @files;
}


sub _item_of {
    my ( $self, $item, $list ) = @_;
    return $$list[$item];
}

# XXX: Move story/media to respective classes
sub _index_of {
    my ( $self, $item, $list ) = @_;

    if ( $item =~ m|\d+/\d+/\d+| ) {
	my $count = 0;
	for my $i ( @$list ) {
	    my $path = $i->story_path_from_full();
	    return $count if $path =~ /$item$/;
	    $count++;
	}
    }

    if ( $item =~ /(\D\D\D)$/ ) {
	
	my $count = 0;
	for my $i ( @$list ) {
	    # Handle list of objects by using file member
	    $i = $i->{file} if defined $i->{file};
	    return $count if $i =~ /$item$/;
	    $count++;
	}
    }
    return $item;
}

#### Public interface ####

# Return array of all elements in list (without args)
#
sub list { }


# Return index 'count' ahead of 'start'
#
sub next {
    my ( $self, %param ) = @_;

    $param{start} = $self->_index_of( $param{start}, $param{list} );

    return undef if $param{start} >= $param{end};
    my $index = $param{start} + $param{count};
    return undef if $index > $param{end};
    return $index;
}


# Return index 'count' behind 'start'
#
sub prev {
    my ( $self, %param ) = @_;

    $param{start} = $self->_index_of( $param{start}, $param{list} );

    return undef if $param{start} <= 0;
    my $index = $param{start} - $param{count};
    return $param{end} if $index > $param{end};
    return 0 if $index < 0;
    return $index;
}

__END__

=head1 NAME

Spoejs::List - General list module for stories, channels, media, etc.

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

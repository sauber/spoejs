package Spoejs::List;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: List.pm,v 1.5 2004/03/29 06:52:17 snicki Exp $
$Spoejs::List::VERSION = $Spoejs::List::VERSION = '$Revision: 1.5 $';


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
    find sub {
	my $res = $File::Find::name if /$file$/;
	return unless $res;
	$res =~ s/\/$file//;      #Strip filename

	push @paths, $res;
    },
    $path;

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
	my $res = $File::Find::name if /$pattern$/;
	push @files, $res if $res;
    },
    $self->{path};

    return @files;
}

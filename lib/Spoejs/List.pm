package Spoejs::List;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: List.pm,v 1.2 2004/03/11 09:30:08 snicki Exp $
$Spoejs::List::VERSION = $Spoejs::List::VERSION = '$Revision: 1.2 $';


# Constructor
# Anticipated params: 
#   'path' - path to dir to work from
#
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );
}

#### Private helper functions ####

# Give list of dirs in given path
#
sub _dirs_in_path {
    my ( $self, $path ) = @_;

    opendir DH, "$path" or die $self->_err( "Can not open $path: $!");
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

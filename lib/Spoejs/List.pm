package Spoejs::List;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: List.pm,v 1.1 2004/03/06 09:11:14 snicki Exp $
$Spoejs::List::VERSION = $Spoejs::List::VERSION = '$Revision: 1.1 $';


# Constructor
# Anticipated params: 
#   'path' - path to dir to work from
#
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );
}

#### Private helper functions ####


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

package Spoejs::ChannelList;
use base ( "Spoejs::List", "Spoejs" );
use Spoejs::ChannelConf;
use Data::Dumper;

# $Id: ChannelList.pm,v 1.1 2004/03/06 09:13:43 snicki Exp $
$Spoejs::ChannelList::VERSION = $Spoejs::ChannelList::VERSION = '$Revision: 1.1 $';


# Constructor
# Anticipated params: 
#   'path' - path to dir containing user dirs
#
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );

    $self->{file} = "settings.txt";
}

#### Private helper functions ####


#### Public interface ####

# Search channels for given key/value pairs.
# Return only those that satisfies all criteria
#
sub search_channels {

    my ($self, %p ) = @_;

    my @all = $self->_list_from_filename( $self->{path}, $self->{file} );

    my @chans;
    for ( @all ) {
	my $CC = new Spoejs::ChannelConf( path => $_ );
	my %c = $CC->get( keys %p );

	# Check given criteria; remove if satisfied
	foreach my $key (keys %p) {
	    delete $c{$key} if ($p{$key} eq $c{$key});
	}

	# Check that all criteria was removed
	if ( keys %c == 0  ) {
	    push @chans, $CC
	}
    }

    return @chans;
}

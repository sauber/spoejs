package Spoejs::ChannelList;
use base ( "Spoejs::List", "Spoejs" );
use Spoejs::ChannelConf;
use File::Path;

# $Id: ChannelList.pm,v 1.7 2004/03/29 04:25:20 snicki Exp $
$Spoejs::ChannelList::VERSION = $Spoejs::ChannelList::VERSION = '$Revision: 1.7 $';


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

    my @all = $self->_list_from_filename( $self->{path}, $self->{file} )
	or return $self->_err( "Could not get channel list" );

    my @chans;
    for ( @all ) {
	my $CC = new Spoejs::ChannelConf( path => $_, lang => $self->{lang} );

	# Only get() if criterias are given; else we get all instead of none
	my %c = $CC->get( keys %p ) if %p;

	# Check given criteria; remove if satisfied
	foreach my $key (keys %c) {
	    delete $c{$key} if ($p{$key} eq $c{$key});
	}

	# Check that all criteria was removed
	if ( keys %c == 0  ) {
	    push @chans, $CC
	}
    }

    return @chans;
}


# Create directory and settings for a new channel 
#
#skal oprette dir. Channelconf skal skrive en settings.txt
#fil channel configuration
#
sub new_channel {
    
    my ( $self, %params ) = @_;
    
    # Check for correct shortname
    return $self->_err( "$params{shortname} is not a valid shortname - must be"
			 . " 4-10 characters [a-z]" ) 
	unless $params{shortname} =~ /^[a-z]{4,10}$/;

    my @cur_dirs = $self->_dirs_in_path( $self->{path} );

    # Check if dir already exists
    for ( @cur_dirs ) {
	return $self->_err( "$params{shortname} already exists" ) 
	    if $params{shortname} eq $_;
    }

    # Create dir
    my $full_path = "$self->{path}/$params{shortname}";
    mkdir $full_path or 
	return $self->_err( "Could not create directory " . 
			    " $full_path: $!" );

    # Create channel config, adding active='no' as default 
    # XXX: remove created dir if we _err here
    my $CC = new Spoejs::ChannelConf( path => $full_path );
    $params{active} ||= "no";
    $CC->set( %params ) or return $self->_err( "Could not set settings." );

    # Success
    return 1;
}


# Remove channel
#
sub delete_channel {

    my ($self, $channel) = @_;

    # Remove given story-dir
    my $res = rmtree "$self->{path}/$channel";
    return $self->_err( "Could not delete channel: $!" ) unless $res > 0;

    # Success
    return $res;
}


# Archive channel removing channel, leaving tarball of it
#
sub archive_channel {

    my ($self, $channel) = @_;

    # Make archive
    my $path = "$self->{path}/${channel}";
    `tar czf ${path}.tgz $path`;
    
    # Delete chan
    return $self->delete_channel( $channel );
}

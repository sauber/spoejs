package Spoejs::ChannelList;
use base ( "Spoejs::List", "Spoejs" );
use Spoejs::ChannelConf;
use File::Path;
use Date::Manip;
use Data::Dumper;

# $Id: ChannelList.pm,v 1.15 2004/04/04 01:47:16 snicki Exp $
$Spoejs::ChannelList::VERSION = $Spoejs::ChannelList::VERSION = '$Revision: 1.15 $';


# Constructor
# Anticipated params: 
#   'path' - path to dir containing user dirs
#
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );

    $self->{file} = "settings.txt";
    $self->_check_dir();
}

#### Private helper functions ####


#### Public interface ####

# Search channels for given key/value pairs.
# Return only those that satisfies all criteria
#
sub search_channels {

    my ($self, %p ) = @_;

    my @all;
    @all = $self->_list_from_filename( $self->{path}, $self->{file} )
	or return $self->_err( $self->{msg} );
    @all = () if $all[0] eq undef;

    my @chans;
    for my $ch ( @all ) {
	my $CC = new Spoejs::ChannelConf( path => $ch, lang => $self->{lang} );

	# Only get() if criterias are given; else we get all instead of none
	my %c;
	my @k = keys %p;
	if ( @k == 1 ) {
	    # single-key special case
	    $c{$k[0]} = $CC->get( keys %p ) if %p;
	} else {
	    %c = $CC->get( keys %p ) if %p;
	}


	# Check given criteria; remove if satisfied
	foreach my $key (keys %c) {
	    delete $c{$key} if ($p{$key} eq $c{$key});
	}
	# Check that all criteria was removed
	if ( keys %c == 0  ) {
	    push @chans, $CC
	}
    }

    @chans = () if $chans[0] eq undef;

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


# List of channels sorted by newest entry
#
sub newest_channels {
  my ( $self, %params ) = @_;

  # Gives array of ChannelConf object refs
  my @channels;
  @channels = $self->search_channels( public => 'yes' ) unless $self->{msg};
  @channels = () if ( $channels[0] eq undef );


  # Add channels we have auth for 
  my @authchans;
  for $u ( @{$params{auth}} ) {
      my @newc = $self->search_channels( shortname => $u ) 
	  unless $self->{msg};
      @authchans = ( @authchans, @newc );
  }

  @channels = ( @channels,  @authchans ) unless ( $authchans[0] eq undef );

  my %seen = ();
  @channels = grep { ! $seen{$_->get('shortname')} ++ } @channels; # Uniqify

  # Sort channels by date of newest entry
  for my $c ( @channels ) {
    my $SL = new Spoejs::StoryList( lang => $self->{lang},
				    path => $c->{path} );
    my @s = $SL->list_stories( count => 1 );

    # Add date in seconds since epoch
    $c->{newest_date} = $s[0] ? UnixDate($s[0]->get( 'date' ), "%s") : 0;

    # Add story reference for later use
    $c->{S} = $s[0] if $s[0];
  }

  # Sort based on date in seconds
  @channels = sort { $b->{newest_date} <=> $a->{newest_date} } @channels;

  # Shrink array if count is given 
  if ( defined $params{count} ) {
      $#channels = $params{count} - 1 if @channels > $params{count};
  }

  return @channels;
}

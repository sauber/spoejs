package Spoejs::Syndication;
use base ( "Spoejs::Text" );
use Data::Dumper;
use Date::Manip;
use LWP::UserAgent;
use Spoejs::ChannelList;

# $Id: Syndication.pm,v 1.2 2004/05/16 00:33:49 snicki Exp $
$Spoejs::Syndication::VERSION = $Spoejs::Syndication::VERSION = '$Revision: 1.2 $';

# Constructor
sub _initialize {
    my $self  = shift;
    $self->SUPER::_initialize(@_, file => 'syndication.txt' );
}

#### Private helper functions ####

#
#
sub _remote_list {
  my $self = shift;
  my $url  = shift;

  my $ua = LWP::UserAgent->new;
  my $res= $ua->get($url);
  my ($list);
  if ($res->is_success) {
    $list = $res->content;
  } else {
    warn $res->status_line;
    return $self->_err('Could not fetch remote: $url');
  }
  return $list;
}


# Parse remote lists. Format is:
# 1. Channels separated by newline
# 2. Channelname (shortname) and date of newest entry is ;-separated
#
sub _parse_remote_list {
    my $self = shift;
    my $site = shift;
    my $list = shift; # As one string

    my @sname_dates;
    my @lines = split /\n/, $list;
    for my $line ( @lines ) {
	my ($sname, $date) = split /;/, $line;
        push @sname_dates, 
             { site => $site, shortname => $sname, date => $date };
    }
    return @sname_dates;
}


#
#
sub _fetch_remotes {
  my $self  = shift;
  my $remotedoc = "/latest.html"; #XXX: Consider moving to new() call or config
  my %sites = $self->get();

  while ( my ( $site, $url ) = ( each %sites ) ) {
      my $list = $self->_remote_list( $url . $remotedoc );
      push @{$self->{globallist}}, $self->_parse_remote_list( $site, $list );
  }
}


#
#
sub _sort_globallist {
  my $self  = shift;

    @{$self->{globallist}} = 
                sort { $b->{date} <=> $a->{date} }
                      @{$self->{globallist}};
}

#### Public interface ####

# Get simple text list of channels and date of their newest story
#
sub local_channel_newestdate_list {
    my $self  = shift;
 
    my $CL = new Spoejs::ChannelList( path => $self->{path},
				      lang => $self->{lang} );
    return $self->_err("Error creating ChannelList") if $CL->{msg};
    
    my @channels;
    @channels = $CL->newest_channels()  unless $CL->{msg};
    
    my ( @sns, $SL, @s );
    for my $chan (@channels) {
	$SL = new Spoejs::StoryList( lang => $self->{lang},
			     path => $self->{path} . $chan->channel_dir() );
	@s = $SL->list_stories( count => 1 );
	unless ($s[0] eq undef) {
            my $story = $s[0];
            my $date = UnixDate($story->get( 'date' ), "%y%m%d");
	    push @sns, { shortname => $chan->get('shortname'), date => $date};
	}
    }
    
    return @sns;
}


#
#
sub newest_remotes {
  my $self  = shift;

  # Build globallist with all remotes
  $self->_fetch_remotes();

  # Sort on date of newest entry
  $self->_sort_globallist();

}

__END__
                                                                               
=head1 NAME

Spoejs::Story - Text, Attributes, MediaList, Annotations, Comments for a story

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

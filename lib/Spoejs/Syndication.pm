package Spoejs::Syndication;
use base ( "Spoejs" );
use Data::Dumper;
use Date::Manip;
use LWP::UserAgent;
use Spoejs::ChannelList;
use Spoejs::SiteConf;

# $Id: Syndication.pm,v 1.14 2004/05/16 12:18:09 snicki Exp $
$Spoejs::Syndication::VERSION = $Spoejs::Syndication::VERSION = '$Revision: 1.14 $';

# Constructor
sub _initialize {
    my $self  = shift;
#    $self->SUPER::_initialize(@_, file => 'syndication.txt' );
    $self->{siteconf} = new Spoejs::ChannelConf( path => $self->{path},
						 lang => $self->{lang} );
    $self->{proxy} = $self->{siteconf}->get( 'proxy' );
}

#### Private helper functions ####

#
#
sub _fetch_url {
  my $self = shift;
  my $url  = shift;

  my $ua = LWP::UserAgent->new;
  # XXX: Make check for valid proxy stricter
  $ua->proxy( 'http', $self->{proxy} ) if length $self->{proxy} > 10;
  my $res= $ua->get($url);
  my ($content);
  if ($res->is_success) {
    $content = $res->content;
  } else {
    warn $res->status_line;
    return $self->_err('Could not fetch remote: $url');
  }
  return $content;
}


# Parse remote lists. Format is:
# 1. Channels separated by newline
# 2. Channelname (shortname) and date of newest entry is ;-separated
#
sub _parse_remote_list {
    my $self = shift;
    my ( $url, $list ) = @_;

    my @sname_dates;
    my @lines = split /\n/, $list;
    for my $line ( @lines ) {
	my ($sname, $date) = split /;/, $line;
        push @sname_dates, 
            { url => $url, shortname => $sname, date => $date };
    }
    return @sname_dates;
}

#
#
sub _remotes_from_conf {
  my $self  = shift;

  my $list = $self->{siteconf}->get( 'peers' );
  return split /\s+/, $list;
}


#
#
sub _fetch_remote_lists {
  my $self  = shift;
  my $remotedoc = "/latest.html"; #XXX: Consider moving to new() call or config
  my @peers = $self->_remotes_from_conf();

  for my $url ( @peers ) {
      my $list = $self->_fetch_url( $url . $remotedoc ) if length $url > 10;
      push @{$self->{globallist}}, $self->_parse_remote_list( $url, $list );
  }
}


#
#
sub _sort_globallist {
  my $self  = shift;

    @{$self->{globallist}} = sort { $b->{date} <=> $a->{date} }
                             @{$self->{globallist}};
}


#
#
sub _fetch_summaries {
    my $self  = shift;

    for my $chan ( @{$self->{globallist}} ) {
	my $url =  "$chan->{url}/$chan->{shortname}/intro.html";
	$chan->{summary} = $self->_fetch_url( $url );
    }

}


#
#
sub _rewrite_urls {
    my $self  = shift;

    for my $chan ( @{$self->{globallist}} ) {
	my $url = $chan->{url};
	$chan->{summary} =~ 
	       s#(src|href)=(["']?)(?!http://.*?)/(.*?)(["']?)#$1=$2$url/$4$5#g;
    }
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
            my $date = UnixDate($story->get( 'date' ), "%Y%m%d");
	    push @sns, { shortname => $chan->get('shortname'), date => $date};
	}
    }
    
    return @sns;
}


#
#
sub newest_remotes {
  my $self  = shift;
  my %opt   = @_;

  # Build globallist with all remotes
  $self->_fetch_remote_lists();

  # Sort on date of newest entry
  $self->_sort_globallist();

  # Shrink array to 'count' elements
  if ( @{$self->{globallist}} > $opt{count} ) {
      $#{$self->{globallist}} = $opt{count} - 1;
  }

  # Fetch newset summaries
  $self->_fetch_summaries();

  # Rewrite urls so they are absolute
  $self->_rewrite_urls();

  return $self->{globallist};
}

__END__
                                                                               
=head1 NAME

Spoejs::Story - Text, Attributes, MediaList, Annotations, Comments for a story

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

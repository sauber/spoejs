package Spoejs::Syndication;
use base ( "Spoejs" );
use Data::Dumper;
use Date::Manip;
use LWP::UserAgent;
use Spoejs::ChannelList;

# $Id: Syndication.pm,v 1.1 2004/05/15 09:28:20 snicki Exp $
$Spoejs::Syndication::VERSION = $Spoejs::Syndication::VERSION = '$Revision: 1.1 $';

# Constructor
sub _initialize {
    my $self  = shift;

}

#### Private helper functions ####

#
#
sub _remote_list {
  my $self  = shift;
  my $url = shift;

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


#### Public interface ####

# Get simple text list of channels and date of their newest story
#
sub channel_newestdate_list {
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
            my $date = UnixDate($story->get( 'date' ), "%d/%m/%y");
	    push @sns, { shortname => $chan->get('shortname'), date => $date};
	}
    }
    
    return @sns;
}


__END__
                                                                               
=head1 NAME

Spoejs::Story - Text, Attributes, MediaList, Annotations, Comments for a story

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

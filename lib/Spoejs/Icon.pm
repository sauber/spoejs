package Spoejs::Icon;
use LWP::UserAgent;
no Carp::Assert;
use base ( "Spoejs::Media" );

# $Id: Icon.pm,v 1.3 2004/02/29 08:56:55 sauber Exp $
$Spoejs::Icon::VERSION = $Spoejs::Icon::VERSION = '$Revision: 1.3 $';

#### Private interface ####

# Search on google and download the most square icon
#
my $downloadicon = sub {
  my($self,$category) = @_;

  my $ua = LWP::UserAgent->new;
  $ua->agent('Lynx/2.8.4rel.1 libwww-FM/2.14');

  # Perform the search
  my $r= $ua->get("http://images.google.com/images?q=%22$category%22&imgsz=small");
  my ($index);
  if ($r->is_success) {
    $index = $r->content;
  } else {
    warn $r->status_line;
    return undef;
  }

  # Identify all links and their sizes
  my(@l,@p);
  for ( split /\n/, $index ) {
    push @l,m,src=(/images.q=.*?) ,g;
    push @p,m,(\d+ x \d+ pixels) -,g;
  }

  # Calculate squaredness
  # And combine links with squaredness
  my(@I,$n);
  for $n ( 0 .. $#p ) {
    my($x,$y) = $p[$n] =~ m/\d+/g;
    my $s = $y/$x; $s = 1/$s if $s > 1;
    $I[$n]{link} = $l[$n];
    $I[$n]{xyrt} = $s;
  }

  # Did we get at least one picture? Otherwise pass on Google's
  # misspelling suggestion or unknown.
  unless ( @I ) {
    $index =~ m/Did you mean:.*?<i>(.*?)<\/i>/;
    $self->{_didyoumean} = $1 || 'unknown';
    return undef;
  }

  # sort by squaredness
  @I = sort { $b->{xyrt} <=> $a->{xyrt} } @I;

  # Downloading most square picture
  $r = $ua->get( "http://images.google.com$I[0]{link}" );
  if ($r->is_success) {
    $self->{_blob} = $r->content;
    return 1;
  } else {
    warn $r->status_line;
    return undef;
  }
};

#### Public interface ####

sub get {
  my($self,%data) = @_;

  $self->$downloadicon($data{category})
    || $self->$downloadicon($self->{_didyoumean});
  return undef unless $self->{_blob};

  # If size is specified then convert to imagemagick object, scale, and
  # convert back to jpeg again.
  if ( $data{size} ) {
    $self->scale($data{size});
  }

  return \$self->{_blob};
}

1;

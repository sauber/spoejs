package Spoejs::Icon;
use LWP::UserAgent;
use base ( "Spoejs::Media" );

# $Id: Icon.pm,v 1.6 2004/03/30 04:29:43 snicki Exp $
$Spoejs::Icon::VERSION = $Spoejs::Icon::VERSION = '$Revision: 1.6 $';

#### Private interface ####

# Search on google and download the most square icon
#
sub _downloadicon {
  my($self,$category,$size) = @_;

  my $ua = LWP::UserAgent->new;
  $ua->timeout(5); # XXX: Reconsider timeout when in production
  $ua->agent('Lynx/2.8.4rel.1 libwww-FM/2.14');

  # Perform the search
  my $r= $ua->get("http://images.google.com/images?q=%22$category%22&imgsz=small");
  my ($index);
  if ($r->is_success) {
    $index = $r->content;
  } else {
    warn $r->status_line;
    return $self->_err('Could not find any matching pictures');
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
    # Also consider size of picture if size desired size is specified
    if ( $size ) {
      my $xy = ( $x * $y ) / ( $size * $size ); $xy = 1/$xy if $xy > 1;
      $s *= $xy;
    }
    $I[$n]{link} = $l[$n];
    $I[$n]{xyrt} = $s;
  }

  # Did we get at least one picture? Otherwise pass on Google's
  # misspelling suggestion or unknown.
  unless ( @I ) {
    $index =~ m/Did you mean:.*?<i>(.*?)<\/i>/;
    $self->{_didyoumean} = $1 || 'unknown';
    return $self->_err('No mathing pictures. Try alternative.');
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
    return $self->_err('Picture cannot be downloaded');
  }
};

#### Public interface ####

sub get {
  my($self,%data) = @_;

  $self->_downloadicon($data{category},$data{size})
    || $self->_downloadicon($self->{_didyoumean});
  return $self->_err('No picture downloaded') unless $self->{_blob};

  # If size is specified then convert to imagemagick object, scale, and
  # convert back to jpeg again.
  if ( $data{size} ) {
    $self->scale($data{size});
  }

  return \$self->{_blob};
}

1;

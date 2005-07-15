package Spoejs::Icon;
use LWP::UserAgent;
use base ( "Spoejs::Media" );

# $Id: Icon.pm,v 1.15 2005/07/15 10:42:20 sauber Exp $
$Spoejs::Icon::VERSION = $Spoejs::Icon::VERSION = '$Revision: 1.15 $';

# Initializor
#
sub _initialize {
  my($self) = shift;

  # Default path for site local icon library
  $self->{path} ||= "$ENV{DOCUMENT_ROOT}/../lib/icons";
}

#### Private interface ####

# Search on google and download the most square icon
#
sub _downloadicon {
  my($self,$category,$size) = @_;

  my $ua = LWP::UserAgent->new;
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
    $I[$n]{xyrt} = $s**3;
  }

  # Did we get at least one picture? Otherwise pass on Google's
  # misspelling suggestion or unknown.
  unless ( @I ) {
    $index =~ m/Did you mean:.*?<i>(.*?)<\/i>/;
    $self->{_didyoumean} = $1 || 'Icon' . 1 + int rand 99;
    return $self->_err('No mathing pictures. Try alternative.');
  }

  # sort by squaredness
  #@I = sort { $b->{xyrt} <=> $a->{xyrt} } @I;

  # Weighted random choice based upon size and squaredness
  my $t; $t += $_->{xyrt} for @I;
  my $link;
  while ( not $link ) {
    $rand = rand $t;
    for my $i ( @I ) {
      if ( ( $rand -= $i->{xyrt} ) < 0 ) {
        $link = $i->{link};
        last;
      }
    }
  }


  # Downloading most square picture
  #$r = $ua->get( "http://images.google.com$I[0]{link}" );
  $r = $ua->get( "http://images.google.com$link" );
  if ($r->is_success) {
    $self->{_blob} = $r->content;
    return 1;
  } else {
    warn $r->status_line;
    return $self->_err('Picture cannot be downloaded');
  }
};

# Local icon from disk
#
sub _localloadicon {
  my($self,$category) = @_;

  $self->_create_bs();
  my $bscat = $self->{_BS}->encode($category);
  #warn "Cat=$category bscat=$bscat";

  for my $f ( $self->_list_local() ) {
    #warn "Testing local file $f";
    if ( $f =~ /^$bscat\.\w+$/ ) {
      # Local icon that matches category is found
      $self->{file} = $f;
      #warn "$f matches $bscat";
      return $self->load();
    }
  }

  #No matching local icon file
  return undef;
}

# Read list of local icon files from disk
#
sub _list_local {
  my($self) = @_;

  # Check that path is specified and dir exists
  return $self->_err("Path missing") unless $self->{path};
  return $self->_err("Path not readable") unless -d $self->{path};

  # Read files that has underscore and extension
  opendir DH, $self->{path};
    my @files = grep /_.*\.\w+/, readdir DH;
  closedir DH;

  return @files;
}


#### Public interface ####

sub get {
  my($self,%data) = @_;

  # Try several times to get an icon, first local, then from google
  $self->_localloadicon($data{category})
    || $self->_downloadicon($data{category},$data{size},'small')
    || $self->_downloadicon($self->{_didyoumean},$data{size},'small')
    || $self->_downloadicon($data{category},$data{size})
    || $self->_downloadicon($self->{_didyoumean},$data{size});
  return $self->_err('No picture downloaded') unless $self->{_blob};

  # If size is specified then convert to imagemagick object, scale, and
  # convert back to jpeg again.
  if ( $data{size} ) {
    $self->scale($data{size});
  }

  return \$self->{_blob};
}

# Generate list of static categories on server
#
sub list {
  my($self) = @_;

  # Read list of files
  my @files = $self->_list_local();
  return undef if @files and not $files[0];

  # Return list of BS decoded filenames without extensions.
  $self->_create_bs();
  return map { /(.*)\.\w+/ and $self->{_BS}->decode($1) } @files;
}

1;

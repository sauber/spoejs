package Spoejs::Movie;
use base ( "Spoejs::Media" );
use Data::Dumper;
use Video::Info;

# $Id: Movie.pm,v 1.2 2004/04/18 14:27:43 snicki Exp $
$Spoejs::Movie::VERSION = $Spoejs::Movie::VERSION = '$Revision: 1.2 $';
 
# Initializor
#
sub _initialize {
  my($self) = shift;
  # Set supported extensions and call Media's initializer
  $self->{extensions} = 'avi|mpg|wmv|asf|mov';
  $self->_check_save();
}
 
#### Private helper functions ####
 
 
#### Public interface ####
sub load {
  my($self) = @_;

  my $mov = "$self->{path}/$self->{file}";

  # XXX: Add random/uniqueness to tmp filename
  my $tmp = "/tmp/$self->{file}.jpg";
  my $cmd = "ffmpeg -y -t 00:00:00.01 -i $mov -f singlejpeg $tmp";
  system("$cmd > /dev/null 2>&1");
  return $self->_err( "Unable to extract frame" ) if $?;

  my $tmpslash = $/;
  undef $/;
  open _PIC, "$tmp" or return $self->_err( "unable to open file $tmp: $!" );
    binmode _PIC;
    $self->{_blob} = <_PIC>;
  close _PIC;
  $/ = $tmpslash;

  unlink $tmp;

  return \$self->{_blob};
}


sub ping {
  my($self) = shift;

  my $info = Video::Info->new(-file=>"$self->{path}/$self->{file}"); 

  return ($info->width(), $info->height(), $info->filesize(), $info->type());
}

# Get width/height string for use in HTML
#
sub html_imgsize {
  my( $self, %params ) = @_;

  return undef unless ( $self->{file} && $self->{path} && $params{size} );

  my($w,$h) = $self->ping();

  return undef if ( $w == 0 || $h == 0 );

  # Scale shortest side
  my $x = $y = $params{size};
  $x = int( $x * $w / $h ) if $w < $h;
  $y = int( $y * $h / $w ) if $w > $h;

  return "width=\"$x\" height=\"$y\"";
}

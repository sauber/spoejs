package Spoejs::Movie;
use base ( "Spoejs::Media" );
use Data::Dumper;

# $Id: Movie.pm,v 1.8 2004/05/22 15:00:32 sauber Exp $
$Spoejs::Movie::VERSION = $Spoejs::Movie::VERSION = '$Revision: 1.8 $';

# Supported extensions
$Spoejs::Movie::EXTENSIONS = 'avi|mpg|wmv|asf|mov|qt|mpeg|mpe';

# Initializor
#
sub _initialize {
  my($self) = shift;
  # Set supported extensions and call Media's initializer
  $self->{extensions} = $Spoejs::Movie::EXTENSIONS;
  $self->_check_save();
}
 
#### Private helper functions ####
 
 
#### Public interface ####
sub load {
  my($self) = @_;


  my $mov = "$self->{path}/$self->{file}";

  # Get duration of movie
  my $info = `mplayer -identify $mov`;
  my($sec);
  if ( $info =~ /ID_LENGTH=(\d+)/ and $1 > 1 ) {
    $sec = $1;
  } elsif  ( $info =~ /MOV track #\d+: (\d+) chunks/ and $1 > 1 ) {
    $sec = $1;
  } else {
    $sec = 1;
  }

  # Use mplayer to extract one frame from movie
  # 00000001.jpg is sometimes first frame of movie
  # 00000002.jpg is random frame of movie
  my $randomstart = int rand $sec;
  my $tmpdir = "/tmp/.spoejstmp.$$";
  my $tmpfile = $tmpdir . "/00000002.jpg";
  system("mkdir $tmpdir");
  # Add -osdlevel 0 to get rid off seek-indicator
  system("mplayer -really-quiet -ss $randomstart -frames 2 -vo jpeg -jpeg outdir=$tmpdir -nosound $mov");

  # Read in frame from file to internal blob
  my $tmpslash = $/;
  undef $/;
  open _PIC, "$tmpfile" or return $self->_err( "unable to open file $tmpfile: $!" );
    binmode _PIC;
    $self->{_blob} = <_PIC>;
  close _PIC;
  $/ = $tmpslash;

  # Clean up all tmp files
  system("rm -rf $tmpdir");

  return \$self->{_blob};
}

# get geometry, size and format by using mplayer
#
sub ping {
  my($self) = shift;

  my $file = "$self->{path}/$self->{file}";
  my $info = `mplayer -identify $file | grep VIDEO:`;
  my $size = -s $file;
  my($format,$width,$height) = $info =~ /VIDEO:\s+(.*?)\s+(\d+)x(\d+)/;
  return ($width,$height,$size,$format);
}

# Get width/height string for use in HTML
#
sub html_imgsize {
  my( $self, %params ) = @_;

  return undef unless ( $self->{file} && $self->{path} && $params{size} );

  my($w,$h) = $self->ping();

  # Calculate scaled size
  my($x,$y) = $self->_scaledxy($w,$h,$params{size});
  return $self->_err( "Got zero width or height" ) if $x == 0 or $y == 0;

  return "width=\"$x\" height=\"$y\"";
}

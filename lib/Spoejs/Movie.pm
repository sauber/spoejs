package Spoejs::Movie;
use base ( "Spoejs::Media" );
use Data::Dumper;
use Video::Info;

# $Id: Movie.pm,v 1.7 2004/05/09 13:29:01 snicki Exp $
$Spoejs::Movie::VERSION = $Spoejs::Movie::VERSION = '$Revision: 1.7 $';

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


  # Use mplayer to extract one frame from movie
  # 00000001.jpg is sometimes first frame of movie
  # 00000002.jpg is random frame of movie
  my $mov = "$self->{path}/$self->{file}";
  my $info = Video::Info->new(-file=>$mov);
  my $sec = $info->duration();
  my $randomstart = int rand $sec;
  my $tmpdir = "/tmp/.spoejstmp.$$";
  my $tmpfile = $tmpdir . "/00000002.jpg";
  system("mkdir $tmpdir");
  # Add -osdlevel 0 to get rid off seek-indicator
  system("mplayer -really-quiet -ss $randomstart -frames 2 -vo jpeg -jpeg outdir=$tmpdir -nosound $mov");

  my $tmpslash = $/;
  undef $/;
  open _PIC, "$tmpfile" or return $self->_err( "unable to open file $tmpfile: $!" );
    binmode _PIC;
    $self->{_blob} = <_PIC>;
  close _PIC;
  $/ = $tmpslash;

  system("rm -rf $tmpdir");

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

  # Calculate scaled size
  my($x,$y) = $self->_scaledxy($w,$h,$params{size});
  return $self->_err( "Got zero width or height" ) if $x == 0 or $y == 0;

  return "width=\"$x\" height=\"$y\"";
}

# Todo:
# Read/write files
# Perhaps file size check
# Notes:
# $self->{im} is an ImageMagick object

package Spoejs::Media;
use Image::Magick;
no Carp::Assert;
use base ( "Spoejs" );

# $Id: Media.pm,v 1.3 2004/02/28 07:05:13 sauber Exp $
$Spoejs::Media::VERSION = $Spoejs::Media::VERSION = '$Revision: 1.3 $';

#### Private helper functions ####

# strip illegal chars from filename
#
my $valid_name = sub {
    my($self,$f) = @_;

    $f =~ tr/A-Z/a-z/;                        # Only lowercase letters
    $f =~ s/[^a-z0-9.]//g;                  # Only letters and numbers
    while ( $f =~ s/(.*)\.(.*)\.(.+?)/$1$2\.$3/g ) {}   # Only one dot
    return $f;
};

# Scale current image magick object to specified maxside
#
sub scale {
  my($self,$m) = @_;

  return undef unless $self->{im};
  my($w,$h) = $self->info();
  if ( $w>$h ) { $x=$m; $y = int .5 + $m*$h/$w }
          else { $y=$m; $x = int .5 + $m*$w/$h }
   $self->{im}->Scale(width=>$x,height=>$y);
};

#### Public interface ####

# Get size etc about current image magick object
sub info {
  my($self) = @_;

  return undef unless $self->{im};
  return $self->{im}->Get('width','height','filesize','Magick')
}


1;

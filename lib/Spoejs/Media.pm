# Todo:
# Read/write files
# Perhaps file size check
# Notes:
# $self->{_im} is an ImageMagick object
# $self->{_blob} is raw image

package Spoejs::Media;
use Image::Magick;
no Carp::Assert;
use base ( "Spoejs" );

# $Id: Media.pm,v 1.4 2004/02/29 08:57:01 sauber Exp $
$Spoejs::Media::VERSION = $Spoejs::Media::VERSION = '$Revision: 1.4 $';

#### Private helper functions ####

# strip illegal chars from filename
#
sub valid_name {
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

  return undef unless $self->{_im} or $self->{_blob};

  # Convert from blob to im first ?
  my($blob);
  unless ( $self->{_im} ) {
    $self->{_im} = Image::Magick->new(magick=>'jpg');
    $self->{_im}->BlobToImage($self->{_blob});
    $blob = not undef;
  }

  my($w,$h) = $self->info();
  if ( $w>$h ) { $x=$m; $y = int .5 + $m*$h/$w }
          else { $y=$m; $x = int .5 + $m*$w/$h }
  $self->{_im}->Scale(width=>$x,height=>$y);

  # Convert back to blob?
  if ( $blob ) {
    $self->{_blob} = $self->{_im}->ImageToBlob();
    undef $self->{_im};
  }
};

#### Public interface ####

# Get size etc about current image magick object
sub info {
  my($self) = @_;

  return undef unless $self->{_im};
  return $self->{_im}->Get('width','height','filesize','Magick');
}


1;

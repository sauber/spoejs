# Todo:
# Read/write files
# Perhaps file size check
# Notes:
# $self->{_im} is an ImageMagick object
# $self->{_blob} is raw image

package Spoejs::Media;
use Image::Magick;
use Bootstring;
no Carp::Assert;
use base ( "Spoejs" );

# $Id: Media.pm,v 1.6 2004/03/25 03:48:48 snicki Exp $
$Spoejs::Media::VERSION = $Spoejs::Media::VERSION = '$Revision: 1.6 $';

#### Private helper functions ####

# strip illegal chars from filename
#
sub valid_name {
    my($self) = @_;

    my ($file, $ext);
    $file = $self->{file};
    $file =~ s/(.*)(\.)(....?)$/$1/ and $ext = $3;
    my @basic = eval "a..z, A..Z, 0..9";
  my $BS = new Bootstring( BASIC => \@basic, 
	TMAX => 53,
	SKEW => 78,
	INITIAL_BIAS => 32,
	TMIN => 38,
	DAMP => 40,
 );
    $file = $BS->encode( $file );

    $self->{file} = "$file.$ext";
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

sub _create_bs {
    my @basic = eval "a..z, A..Z, 0..9";
    return new Bootstring( BASIC => \@basic, 
			   TMAX => 53,
			   SKEW => 78,
			   INITIAL_BIAS => 32,
			   TMIN => 38,
			   DAMP => 40,
			   );
}

#### Public interface ####

# Get size etc about current image magick object
sub info {
  my($self) = @_;

  return undef unless $self->{_im};
  return $self->{_im}->Get('width','height','filesize','Magick');
}

sub utf_filename {
    my($self) = @_;

    my $BS = _create_bs();
    my ($file, $ext);
    $file = $self->{file};
    $file =~ s/(.*)\.(...)$/$1/ and $ext = $2;
    $file = $BS->decode( $file );
    return $file . '.' . $ext;
}


sub rename {
    my ( $self, $new_file ) = @_;

    my $old_file = "$self->{path}/$self->{file}";

    my $BS = _create_bs();

    $self->{file} = $new_file;
    $self->valid_name();

    rename "$old_file", "$self->{path}/$self->{file}" or warn "rename: $!";
}

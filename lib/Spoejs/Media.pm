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

# $Id: Media.pm,v 1.9 2004/03/29 11:39:38 snicki Exp $
$Spoejs::Media::VERSION = $Spoejs::Media::VERSION = '$Revision: 1.9 $';

#### Private helper functions ####

# strip illegal chars from filename
#
sub valid_name {
    my($self) = @_;
    
    my ($file, $ext);
    $file = $self->{file};
    $file =~ s/(.*)(\.)(....?)$/$1/ and $ext = lc $3;
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
    $self->{_im} = Image::Magick->new();
    $self->{_im}->BlobToImage($self->{_blob});
    $blob = not undef;
  }

  my($w,$h) = $self->info();
  warn "Got zero width or height: w: $w, h: $h" if $w == 0 or $h == 0;
  return $self->_err( "Got zero width or height" ) if $w == 0 or $h == 0;
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

    rename "$old_file", "$self->{path}/$self->{file}" or 
	return $self->_err( "rename failed: $!" );
}


sub delete {
    my ( $self ) = shift;
    return unlink "$self->{path}/$self->{file}";
}

# Get info (IM->Ping) about pic
#
sub ping {
    my( $self, %params ) = @_;
    
    return undef unless ( $self->{file} && $self->{path} );
    
    # Use Image:Magick's ping to get resolution of image
    my $im = Image::Magick->new();
    return $im->Ping( "$self->{path}/$self->{file}" );
}

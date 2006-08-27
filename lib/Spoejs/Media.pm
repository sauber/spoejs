# Todo:
# Read/write files
# Perhaps file size check
# Use global BS object instead of creating every time.
# Notes:
# $self->{_im} is an ImageMagick object
# $self->{_blob} is raw image

package Spoejs::Media;
use Image::Magick;
use Bootstring;
no Carp::Assert;
use base ( "Spoejs" );
use Data::Dumper;
# $Id: Media.pm,v 1.32 2006/08/27 14:13:25 sauber Exp $
$Spoejs::Media::VERSION = $Spoejs::Media::VERSION = '$Revision: 1.32 $';


# Initializor
#
sub _initialize {
  my($self) = shift;

  $self->{path} ||= '.';
  return $self->_err( "Must give file to new" ) unless $self->{file};

  my @attrib = qw ( path file fh size );
  my %opt;
  @opt{ @attrib } = @{$self}{@attrib};

  my $newobj = new Spoejs::Pic( %opt );
  $newobj = new Spoejs::Movie( %opt ) if defined $newobj->{msg};
  $newobj = new Spoejs::Archive( %opt ) if defined $newobj->{msg};
  $newobj->{msg} = "$self->{file}: Unsupported filetype" if defined $newobj->{msg};
  return $newobj;
}


#### Private helper functions ####

sub _check_save {
  my $self = shift;

  # Check for supported extension and save if filehandle is given
  if ( $self->{file} =~ /($self->{extensions})$/i ) {
      if ( defined $self->{fh} ) {
	  $self->save( $self->{fh} );
	  return $self->_check();
      } else {
	  return -s "$self->{path}/$self->{file}" ? 1 : 
	      $self->_err( "Zero-sized file" );
      }
  } else {
      return $self->_err( "$self->{file}: Unsupported filetype" );
  }
}

# strip illegal chars from filename
#
sub valid_name {
    my($self) = @_;
    
    my ($file, $ext);
    $file = $self->{file};
    $file =~ s/(.*)(\.)(....?)$/$1/ and $ext = lc $3;
    $self->_create_bs();
    $file = $self->{_BS}->encode( $file );
    $self->{file} = "$file.$ext";
};


# Check file for validity, delete if not valid
#
sub _check {
    my $self = shift;

    my @ret = $self->ping();
    if ( $ret[0] eq undef ) { 
	$self->delete();
	return $self->_err( "Could not recognize filetype, file deleted." );
    }

    # Success
    return 1;
}


# Create IM object from blob
#
sub _blob_to_im {
  my $self = shift;

  return undef unless $self->{_blob};

  $self->{_im} = Image::Magick->new();
  $self->{_im}->BlobToImage($self->{_blob});
}


# Create blob from IM
#
sub _im_to_blob {
  my $self = shift;

  return undef unless $self->{_im};

  $self->{_blob} = $self->{_im}->ImageToBlob();
}


# Scale current image magick object to specified maxside
#
sub scale {
  my($self,%param) = @_;

  return undef unless $self->{_im} or $self->{_blob};

  my $m = $param{size};

  # Convert from blob to im first ?
  my($blob);
  unless ( $self->{_im} ) {
    $self->_blob_to_im();
    $blob = not undef;
  }

  my($w,$h) = $self->info();
  my($x,$y) = $self->_scaledxy($w,$h,$m);
  return $self->_err( "Got zero width or height" ) if $x == 0 or $y == 0;
  $self->{_im}->Scale(width=>$x,height=>$y);

  # After scaling these filters could be applied.
  #$self->{_im}->Normalize();
  #$self->{_im}->Equalize();
  #$self->{_im}->Sharpen();

  # Non-default quality
  if ( $param{quality} ) {
    $self->{_im}->Set( quality => $param{quality} );
  }

  # Convert back to blob?
  if ( $blob ) {
    $self->_im_to_blob();
    undef $self->{_im};
  }
};

# Calculate x,y of scaled image
#
sub _scaledxy {
  my($self,$x,$y,$s) = @_;

  return (0,0) if $y ==0 or $x == 0;

  # Sum of sides is constant to make all pictures look same size regardless
  # of aspect ratio.
  my $r = 1.4 * $s / ($y+$x);
  $x = int .5 + $x * $r;
  $y = int .5 + $y * $r;
  return ($x,$y);
}

#### Public interface ####

# Get blob data from file handle and save as filename
#
sub save {
  my($self,$fh) = @_;

  $self->valid_name(); # Validate member filename

  open _PIC, ">$self->{path}/$self->{file}" or 
         return $self->_err( "Could not open $self->{path}/$self->{file}: $!");
    binmode _PIC;
    while( <$fh> ){ print _PIC $_ }
  close _PIC;

  return  $self->{file};
}


# Load file as blob reference
#
sub load {
  my($self) = shift;

  my $tmpslash = $/;
  undef $/;
  open _PIC, "$self->{path}/$self->{file}" or return undef;
    binmode _PIC;
    $self->{_blob} = <_PIC>;
  close _PIC;
  $/ = $tmpslash;
  return \$self->{_blob};
}


# Get image in certain size
#
sub get {
  my($self,%params) = @_;

  return undef unless $self->{file};
  $self->load() or return undef;
  if ( $params{size} ) {
    #$self->scale( $params{size} );
    $self->scale( %params );
  }
  return \$self->{_blob};
}


# Get size etc about current image magick object
sub info {
  my($self, $scalem ) = @_;

  return undef unless $self->{_im};

  return $self->{_im}->Get('width','height','filesize','Magick');
}

# Rotate 90 degrees clockwise (90) or counterclickwise (270)
sub rotate {
  my( $self, $degrees ) = @_;

  # XXX: Load object into image magick object
  return undef unless $self->{file};
  $self->load() or return undef;
  $self->_blob_to_im();

  # And then rotate it
  $self->{_im}->Rotate( degrees => $degrees );

  # XXX: And now save image... but save requires filehandle instead of blob?
  $self->_im_to_blob();

  open _PIC, ">$self->{path}/$self->{file}" or 
         return $self->_err( "Could not open $self->{path}/$self->{file}: $!");
    binmode _PIC;
    print _PIC $self->{_blob};
  close _PIC;

  return 1;
}


sub utf_filename {
    my($self) = @_;

    my ($file, $ext);
    $file = $self->{file};
    $file =~ s/(.*)\.(...)$/$1/ and $ext = $2;
    $self->_create_bs();
    $file = $self->{_BS}->decode( $file );
    return $file . '.' . $ext;
}


sub rename {
    my ( $self, $new_file ) = @_;
    
    my $old_file = "$self->{path}/$self->{file}";
    
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

    my ( $w,$h,$s,$f ) = $im->Ping( "$self->{path}/$self->{file}" );
    ($w,$h) = $self->_scaledxy( $w, $h, $params{scalem} ) 
	if defined $params{scalem};
  return ( $w,$h,$s,$f );
}

# List of supported extensions seperated by |
#
sub extenxions {
    return $self->{extensions};
}

# Generate hash of extended information about file
#
sub extinfo {
 return \{};
}

__END__

=head1 NAME

Spoejs::Media - General media module for pictures, movies and icons

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

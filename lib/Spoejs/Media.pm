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
use Data::Dumper;
# $Id: Media.pm,v 1.14 2004/05/08 05:06:18 snicki Exp $
$Spoejs::Media::VERSION = $Spoejs::Media::VERSION = '$Revision: 1.14 $';


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
  $newobj->{msg} = "Unsupported filetype" if defined $newobj->{msg};
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
      return $self->_err( "Unsuported filetype" );
  }
}

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


# Check file for validity, delete if not valid
#
sub _check {
    my $self = shift;

    unless ( $self->ping() ) { 
	$self->delete();
	return $self->_err( "Could not recognize filetype, file deleted." );
    }

    # Success
    return 1;
}


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
    $self->scale( $params{size} );
  }
  return \$self->{_blob};
}


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

# List of supported extensions seperated by |
#
sub extenxions {
    return $self->{extensions};
}

__END__

=head1 NAME

Spoejs::Media - General media module for pictures, movies and icons

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

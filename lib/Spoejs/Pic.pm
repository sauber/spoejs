package Spoejs::Pic;
use base ( "Spoejs::Media" );
use Data::Dumper;
# $Id: Pic.pm,v 1.11 2004/04/09 17:18:39 sauber Exp $
$Spoejs::Pic::VERSION = $Spoejs::Pic::VERSION = '$Revision: 1.11 $';

# Initializor
#
sub _initialize {
  my($self) = shift;

  $self->{path} ||= '.';
  return $self->_err( "Must give file to new" ) unless $self->{file};
}


#### Private helper functions ####


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
  my($self) = @_;

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


# Get width/height string for use in HTML
#
sub html_imgsize {
  my( $self, %params ) = @_;

  return undef unless ( $self->{file} && $self->{path} && $params{size} );

  # Use Image:Magick's ping to get resolution of image
  my $im = Image::Magick->new();
  my($w,$h) = $im->Ping("$self->{path}/$self->{file}");

  return undef if ( $w == 0 || $h == 0 );

  # Scale shortest side
  my $x = $y = $params{size};
  $x = int( $x * $w / $h ) if $w < $h;
  $y = int( $y * $h / $w ) if $w > $h;

  return "width=\"$x\" height=\"$y\"";
}

__END__

=head1 NAME
                                                                                
Spoejs::Pic - Picture operations

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

package Spoejs::Pic;
use base ( "Spoejs::Media" );
use Data::Dumper;
# $Id: Pic.pm,v 1.12 2004/04/18 23:57:23 snicki Exp $
$Spoejs::Pic::VERSION = $Spoejs::Pic::VERSION = '$Revision: 1.12 $';

# Initializor
#
sub _initialize {
  my($self) = shift;

  # Set supported extensions and call Media's initializor
  $self->{extensions} = 'jpg|png|gif|bmp';
  $self->_check_save();

  # Check if file is ok and rotate
  if ( $self->ping() and defined $self->{fh} ) {
      # XXX: Not-portable
      my $fp = "$self->{path}/$self->{file}";
      my $jh = `which jhead`;
      chomp $jh;
      `jhead -autorot $fp` if -f $jh;
  }
}


#### Private helper functions ####


#### Public interface ####

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

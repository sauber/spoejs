package Spoejs::Pic;
use base ( "Spoejs::Media" );
use Data::Dumper;
# $Id: Pic.pm,v 1.20 2004/08/14 07:10:36 sauber Exp $
$Spoejs::Pic::VERSION = $Spoejs::Pic::VERSION = '$Revision: 1.20 $';

# Supported extensions
$Spoejs::Pic::EXTENSIONS = 'jpg|jpeg|png|gif|bmp';

# Initializor
#
sub _initialize {
  my($self) = shift;

  # Set supported extensions and call Media's initializor
  $self->{extensions} = $Spoejs::Pic::EXTENSIONS;
  $self->_check_save();
  return undef if defined $self->{msg};

  # Check if file is ok and rotate
  if (  defined $self->{fh} and $self->ping() ) {
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

  # Calculate scaled size
  my($x,$y) = $self->_scaledxy($w,$h,$params{size});
  return $self->_err( "Got zero width or height" ) if $x == 0 or $y == 0;

  return "width=\"$x\" height=\"$y\"";
}

# Retrieve extended info from image file, such as fx EXIF
#
sub extinfo {
  my( $self, %params ) = @_;

  return undef unless ( $self->{file} && $self->{path} );
  return $self->_err("$self->{path}/$self->{file} does not exist")
    unless -f "$self->{path}/$self->{file}";

  # Image::Info sometimes hang, or sometimes coredumps!! So we have to deal
  # with that :-p Better spawn an external process to protext httpd.
  my $o;
  eval{
    local $SIG{ALRM} = sub { die "timeout\n" };
    alarm 2;
    $o = `perl -e 'use Image::Info qw(image_info);\$i=image_info("$self->{path}/$self->{file}");for(sort{lc(\$a)cmp lc(\$b)}keys%\$i){print"\$_|!|\t\$i->{\$_}|!|\n\n"unless ref(\$i->{\$_});}'`;
    alarm 0;
  };

  my %picinfo;
  for ( grep /\|\!\|\t/, split /\|\!\|\n\n/, $o ) {
    my($k,$v) = split /\|\!\|\t/;
    #print "$k : $v\n";
    $picinfo{$k} = $v;
  }

  return \%picinfo;
}

__END__

=head1 NAME
                                                                                
Spoejs::Pic - Picture operations

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

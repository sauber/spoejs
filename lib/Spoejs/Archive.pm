package Spoejs::Archive;
use base ( "Spoejs::Media" );
use Spoejs::Pic;
use Archive::Zip;
use Archive::Tar;

# $Id: Archive.pm,v 1.10 2004/05/08 05:06:18 snicki Exp $
$Spoejs::Archive::VERSION = $Spoejs::Archive::VERSION = '$Revision: 1.10 $';

# Supported extensions
$Spoejs::Archive::EXTENSIONS = 'tar|gz|tgz|zip';

# Initializor
#
sub _initialize {
  my($self) = shift;
  # Set supported extensions and call Media's initializor
  $self->{extensions} = $Spoejs::Archive::EXTENSIONS;

#  Media::_check_save(); is copied here in modified form

  # Check for supported extension and save if filehandle is given
  if ( $self->{file} =~ /($self->{extensions})$/i ) {
      if ( defined $self->{fh} ) {
	  $self->add_archive();
      } else {
	  return -s "$self->{path}/$self->{file}" ? 1 : 
	      $self->_err( "Zero-sized file" );
      }
  } else {
      return $self->_err( "Unsuported filetype" );
  }


}


#### Private helper functions ####

sub _disk_space {
  my ( $self, $dir ) =@_;

  $dir ||= '.';
  $_ = `df -k $dir`;
  my @fields = split;
  if( @fields < 11 ){
    return $self->_err( "bad return from df" );
  }
  return (0 + $fields[10])*1024;
}
#### Public interface ####

sub add_archive {
  my $self = shift;

  use File::Temp qw/ tempdir /;
  use File::Path;

  my $tempdir;
  my %tries;
  # Check available space
  # XXX: Unix specific
  foreach my $t ( qw( /tmp /var/tmp ), "$self->{path}/../../../../../../data" )
  {
      my $free = $self->_disk_space( $t );
      $tries{$t} = $free;
      # We need atleast double the diskspace for extraction
      if ( 2 * $self->{size} < $free ) {
	  $tempdir = $t;
	  last;
      }
  }
  my $err = "Not enough free diskspace:";
  while ( my ($k, $v) = each %tries ) { $err .= " $k ( $v )"; }
  return $self->_err( $err ) unless $tempdir;

  # Make temp-dir
  my $template = $tempdir . "/spoejs-arhive-XXXXXXX";
  $tempdir = tempdir ( $template );

  chomp(my $oldwd = `pwd`); # XXX: Only UNIX
  chdir $tempdir;

  # Store archive
  open _FH, ">$tempdir/$self->{file}" 
      or return $self->_err( "Could not save archive to $tempdir/$self->{file}: $!" );
   binmode _FH;
    my $fh = $self->{fh};
    while( <$fh> ){ print _FH $_ }
  close _FH;

  if ( $self->{file} =~ /\.zip/ ) {
    # Open archive
    my $zip = Archive::Zip->new( "$tempdir/$self->{file}" ) 
	or return $self->_err( "Couldn't open zip" );

    # Extract members
    my @members = $zip->members();

    for my $mem ( @members ) {
      $zip->extractMemberWithoutPaths( $mem );
    }

  } elsif ( $self->{file} =~ /\.(tar|gz|tgz)$/ ) {

    my $tar = Archive::Tar->new;
    $tar->read( "$tempdir/$self->{file}" );
    $tar->extract();

  }

  # Remove archive
  unlink "$tempdir/$self->{file}";

  # Add unpacked files
  $self->add_dir( $tempdir );

  # Cleanup
  chdir $oldwd;
  rmtree $tempdir;

  # Sucess
  return 1;
}


sub add_dir {
  my ( $self, $dir ) = @_;

  # XXX: Convert to File::Find to support nested dirs
  opendir DH, $dir or return $self->_err( "Can't open $dir: $!" );

  while( my $file = readdir DH ) {
    if ( -f "$dir/$file" ) {
      my $fh = new IO::File( "$dir/$file", "r" );
      new Spoejs::Media( path => $self->{path}, file => $file, fh => $fh );
    }
  }

  closedir DH;
}


__END__

=head1 NAME

Spoejs::Archive - Archival of channels

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

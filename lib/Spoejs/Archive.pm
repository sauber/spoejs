package Spoejs::Archive;
use base ( "Spoejs::Media" );
use Spoejs::Pic;
use Archive::Zip;
use Archive::Tar;

# $Id: Archive.pm,v 1.5 2004/03/31 10:01:40 snicki Exp $
$Spoejs::Archive::VERSION = $Spoejs::Archive::VERSION = '$Revision: 1.5 $';

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
  my ( $self, $path, $fn, $fh, $size ) = @_;

  use File::Temp qw/ tempdir /;
  use File::Path;

  my $tempdir;
  my %tries;
  # Check available space
  # XXX: Unix specific
  foreach my $t ( qw( /tmp /var/tmp ), "$path/../../../../../../data" ) {

      my $free = $self->_disk_space( $t );
      $tries{$t} = $free;
      if ( $size < $free ) {
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
  open _FH, ">$tempdir/$fn" 
      or return $self->_err( "Could not save archive to $tempdir/$fn: $!" );
   binmode _FH;
    while( <$fh> ){ print _FH $_ }
  close _FH;

  if ( $fn =~ /\.zip/ ) {
    # Open archive
    my $zip = Archive::Zip->new( "$tempdir/$fn" ) 
	or return $self->_err( "Couldn't open zip" );

    # Extract members
    my @members = $zip->members();

    for ( @members ) {
      $zip->extractMemberWithoutPaths( $_ );
    }

  } elsif ( $fn =~ /\.(tar|gz|tgz)$/ ) {

    my $tar = Archive::Tar->new;
    $tar->read( "$tempdir/$fn" );
    $tar->extract();

  }

  # Remove archive
  unlink "$tempdir/$fn";

  # Add unpacked files
  $self->add_dir( $tempdir, $path );

  # Cleanup
  chdir $oldwd;
  rmtree $tempdir;

  # Sucess
  return 1;
}


sub add_dir {
  my ( $self, $dir, $target ) = @_;

  # XXX: Convert to File::Find to support nested dirs
  opendir DH, $dir or return $self->_err( "Can't open $dir: $!" );

  while( my $file = readdir DH ) {
    if ( -f "$dir/$file" ) {
      my $fh = new IO::File( "$dir/$file", "r" );
      $self->add_file( $target, $file, $fh );
    }
  }

  closedir DH;
}


sub add_file {
  my ( $self, $path, $fn, $fh ) = @_;
  return $self->_err( "Unknown file type" ) unless $fn =~ /(jpg|png|gif)$/i;
  my $P = new Spoejs::Pic( path => $path, file => $fn );
  return $self->_err( $P->{msg} ) if $P->{msg};
  $P->save( $fh ) or return $self->_err( $P->{msg} );

  # Check if file is ok and rotate
  if ( $P->ping() ) {
      # XXX: Not-portable
      my $fp = "$P->{path}/$P->{file}";
      my $jh = `which jhead`;
      chomp $jh;
      `jhead -autorot $fp` if -f $jh;
  } else {
      $P->delete();
  }
  # Success
  return 1;
}


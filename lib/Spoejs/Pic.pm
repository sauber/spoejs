package Spoejs::Pic;
use base ( "Spoejs::Media" );
use Data::Dumper;
# $Id: Pic.pm,v 1.3 2004/03/16 23:00:51 snicki Exp $
$Spoejs::Pic::VERSION = $Spoejs::Pic::VERSION = '$Revision: 1.3 $';

# Initializor
#
sub _initialize {
  my($self) = shift;

  $self->{path} ||= '.';
}


#### Private helper functions ####


#### Public interface ####

# Get blob data from file handle and save as filename
#
sub save {
  my($self,$fh,$filename) = @_;

  $filename = $self->valid_name($filename);
  open _PIC, ">$self->{path}/$filename" or 
             return $self->_err( "Could not open $self->{path}/$filename: $!");
    binmode _PIC;
    while( <$fh> ){ print _PIC $_ }
  close _PIC;

  return  $filename;
}

# Load file as blob reference
#
sub load {
  my($self,$filename) = @_;

  my $tmpslash = $/;
  undef $/;
  open _PIC, "$self->{path}/$filename" or return undef;
    binmode _PIC;
    $self->{_blob} = <_PIC>;
  close _PIC;
  $/ = $tmpslash;
  return \$self->{_blob};
}

# Get image in cercain size
#
sub get {
  my($self,%params) = @_;

  return undef unless $params{file};
  $self->load( $params{file} ) or return undef;
  if ( $params{size} ) {
    $self->scale( $params{size} );
  }
  return \$self->{_blob};
}

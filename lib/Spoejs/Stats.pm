package Spoejs::Stats;
use base ( "Spoejs" );

# $Id: Stats.pm,v 1.2 2004/08/11 12:03:36 sauber Exp $
$Spoejs::Stats::VERSION = $Spoejs::Stats::VERSION = '$Revision: 1.2 $';

# Constructor
#
sub _initialize {
  my $self  = shift;

  %{$self} = ( %{$self}, @_, file => 'stats.log' );
  return $self->_err( "Missing or invalid path: $self->{path}" )
    unless $self->{path};
}

# Read in all stats and store in $self->{_data}
#
sub _read_and_parse {
  my $self = shift;

  $self->_check_save() or return undef;

  # week = 604800 = 60*60*24*7
  # month = 2592000 = 60*60*24*30
  my $weekago = time-604800; my $monthago = time-2592000;
  open LOG, "$self->{path}/$self->{file}" or return
      $self->_err("Could not open $self->{path}/$self->{file} for appending");
    while (<LOG>) {
      chomp;
      my($timestamp,$entry) = split ';';
      $self->{_data}{$entry}{total}++;
      $self->{_data}{$entry}{week}++ if $timestamp > $weekago;
      $self->{_data}{$entry}{month}++ if $timestamp > $monthago;
    }
  close LOG;
  return 1;
}

#### Public interface ####

# Append timestamp;filename to log file
#
sub access {
  my($self,$entry) = @_;

  $self->_check_save() or return undef;
  $self->{is_modified} .= time.";$entry\n";
  return 1;
}

# Delay saving data to disk until object is destroyed
#
sub DESTROY {
  my $self = shift;

  if ( defined $self->{is_modified} ) {
    open LOG, ">>$self->{path}/$self->{file}";
      print LOG $self->{is_modified};
    close LOG;
  } 
}


# Return total, month and week stats for filename
#
sub stats {
  my($self,$entry) = @_;

  $self->_read_and_parse() unless $self->{_data};
  return undef unless $self->{_data};
  return ( $self->{_data}{$entry}{'total'},
           $self->{_data}{$entry}{'month'},
           $self->{_data}{$entry}{'week'} );
}

__END__

=head1 NAME

Spoejs::Stats - Store access information and generate statistics for image views

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

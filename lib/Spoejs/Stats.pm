package Spoejs::Stats;
use base ( "Spoejs" );

# $Id: Stats.pm,v 1.4 2004/08/31 04:05:32 sauber Exp $
$Spoejs::Stats::VERSION = $Spoejs::Stats::VERSION = '$Revision: 1.4 $';

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

  # Don't read data twice
  return 1 if $self->{is_read};
  $self->_check_save() or return undef;
  $self->{is_read} = 1;

  # week = 604800 = 60*60*24*7
  # month = 2592000 = 60*60*24*30
  my $weekago = time-604800; my $monthago = time-2592000;
  open LOG, "$self->{path}/$self->{file}" or return 1;
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
  $self->{_data}{$entry}{total}++;
  $self->{_data}{$entry}{month}++;
  $self->{_data}{$entry}{week}++;
  return 1;
}

# Return total, month and week stats for filename
#
sub stats {
  my($self,$entry) = @_;

  $self->_read_and_parse();
  my @a;
  $a[0] = $self->{_data}{$entry}{total} || 0 ;
  $a[1] = $self->{_data}{$entry}{month} || 0 ;
  $a[2] = $self->{_data}{$entry}{week} || 0 ;
  return @a;
}

# Return topN for total, month and week stats
# Exclude story in counting
# XXX: Not tested yet!
#
sub topN {
  my($self,$N) = @_;

  my @V = ();
  for my $k ( qw(total month week) ) {
    push @V, [ (sort { $self->{_data_}{$a}{$k} <=> $self->{_data_}{$b}{$k} }
               grep !/story/,
               keys %{$self->{_data}})[0..$N-1] ];
  }
  return \@V;
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

__END__

=head1 NAME

Spoejs::Stats - Store access information and generate statistics for image views

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

package Spoejs;

# $Id: Spoejs.pm,v 1.5 2004/03/04 11:43:52 snicki Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.5 $';

# Constructor
#
sub new {

    my $invocant  = shift;
    my $class     = ref($invocant) || $invocant;

    my $self = { @_ };
    bless $self, $class;
    $self->_initialize();

    return $self;
}

# Default initializor
#
sub _initialize {}

# Write error messages to $self->{msg} and return undef
#
sub _err {
  my $self = shift;
  $self->{msg} = shift;
  return undef;
}

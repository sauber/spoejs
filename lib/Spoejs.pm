package Spoejs;

# $Id: Spoejs.pm,v 1.4 2004/03/04 07:26:42 sauber Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.4 $';

# Constructor
#
sub new {

    my $invocant  = shift;
    my $class     = ref($invocant) || $invocant;

    my $self = { };
    bless $self, $class;
    $self->_initialize(@_);

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

package Spoejs;

# $Id: Spoejs.pm,v 1.3 2004/03/02 05:35:49 snicki Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.3 $';

# Constructor
sub new {

    my $invocant  = shift;
    my $class     = ref($invocant) || $invocant;

    my $self = { };
    bless $self, $class;
    $self->_initialize(@_);

    return $self;
}

# Default initializor

sub _initialize {}

package Spoejs;

# $Id: Spoejs.pm,v 1.2 2004/02/28 07:05:03 sauber Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.2 $';

# Constructor
sub new {

    my $invocant  = shift;
    my $class     = ref($invocant) || $invocant;
    my %param     = (@_);

    my $self = { };
    bless $self, $class;
    $self->_initialize(@_);

    return $self;
}

# Default initializor

sub _initialize {}

package Spoejs;

# $Id: Spoejs.pm,v 1.1 2004/02/26 02:51:08 snicki Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.1 $';

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

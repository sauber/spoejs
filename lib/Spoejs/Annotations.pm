package Spoejs::Annotations;
use base ( "Spoejs::Text" );

# $Id: Annotations.pm,v 1.2 2004/05/20 10:51:50 snicki Exp $
$Spoejs::Annotations::VERSION = $Spoejs::Annotations::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_, file => 'annotations.txt' );
    return $self->_err( "Missing or invalid path: $self->{path}" )
        unless $self->{path};
}

__END__

=head1 NAME

Spoejs::Annotations - Handles media annotations.

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

package Spoejs::Annotations;
use base ( "Spoejs::Text" );

# $Id: Annotations.pm,v 1.1 2004/05/20 10:11:06 snicki Exp $
$Spoejs::Annotations::VERSION = $Spoejs::Annotations::VERSION = '$Revision: 1.1 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_, file => 'annotations.txt' );
    return $self->_err( "Missing or invalid path: $self->{path}" )
        unless $self->{path};
    warn "path: $self->{path}  :  file: $self->{file}";
}

__END__

=head1 NAME

Spoejs::Annotations - Handles media annotations.

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

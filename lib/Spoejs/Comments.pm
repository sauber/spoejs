package Spoejs::Comments;
use base ( "Spoejs::Text" );

# $Id: Comments.pm,v 1.2 2004/06/08 09:37:34 snicki Exp $
$Spoejs::Comments::VERSION = $Spoejs::Comments::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize( @_, file => 'comments.txt' );
    return $self->_err( "Missing or invalid path: $self->{path}" )
        unless $self->{path};
}

sub append {
  my ($self, %params ) = @_;
 
  my @keys = keys %params;
  my $key = $keys[0];
  my $old = $self->get( "$key" );
  $self->set( $key => "${old}$params{$key}" );
  return 1;
}

__END__

=head1 NAME

Spoejs::Comments - Handles media/story comments.

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

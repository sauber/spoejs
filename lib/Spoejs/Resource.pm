package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.11 2004/04/10 06:47:45 sauber Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.11 $';

# Set path and filename for resource file
#
sub _initialize {
    my $self = shift;
    # XXX: Spoejs.pm eats @_ before it gets here
    my $path = $self->{path} || $ENV{DOCUMENT_ROOT} || '';
    $self->SUPER::_initialize( path => "$path/../lib/",
			       file => "resource.txt"
                               );
}

# Generate list of languages.
#
sub lang_list {
  my($self) = @_;

  # Read in resource file
  $self->_check_load() or return $self->_err( "Could not load resource.txt" );

  # All two letter keys are languages.
  return sort grep /^..$/, keys %{$self->{data}};
}

# Return list of all keys
#
sub keys {
  my($self) = @_;

  # Read in resource file
  $self->_check_load() or return $self->_err( "Could not load resource.txt" );

  return sort keys %{$self->{data}};
}

__END__

=head1 NAME
                                                                                
Spoejs::Resource - Translations of all webpage text

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

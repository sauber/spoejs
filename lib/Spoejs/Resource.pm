package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.9 2004/04/03 05:22:21 snicki Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.9 $';

# Set path and filename for resource file
#
sub _initialize {
    my $self = shift;
    my $path = $ENV{DOCUMENT_ROOT} || '';
    $self->SUPER::_initialize( @_, 
			       path => "$path/../lib/",
			       file => "resource.txt" );
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

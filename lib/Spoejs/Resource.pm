package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.7 2004/03/07 10:51:05 sauber Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.7 $';

# Set path and filename for resource file
#
sub _initialize {
    my $self = shift;
    my $path = $ENV{DOCUMENT_ROOT} || '';
    $self->SUPER::_initialize( @_, 
			       path => "$path../lib/",
			       file => "resource.txt" );
}

# Generate list of languages.
#
sub lang_list {
  my($self) = @_;

  # Read in resource file
  $self->_check_load();

  # All two letter keys are languages.
  return sort grep /^..$/, keys %{$self->{data}};
}

# Return list of all keys
#
sub keys {
  my($self) = @_;

  # Read in resource file
  $self->_check_load();

  return sort keys %{$self->{data}};
}

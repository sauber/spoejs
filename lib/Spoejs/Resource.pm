package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.6 2004/03/05 03:57:29 sauber Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.6 $';

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

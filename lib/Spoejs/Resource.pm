package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.5 2004/03/04 11:43:52 snicki Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.5 $';

sub _initialize {
    my $self = shift;
    my $path = $ENV{DOCUMENT_ROOT} || '';
    $self->SUPER::_initialize( @_, 
			       path => "$path../lib/",
			       file => "resource.txt" );
}

# Generate list of languages.
sub lang_list {
  my($self) = @_;

  # Read in resource file
  $self->_check_load();

  # All two letter keys are languages.
  return sort grep /^..$/, keys %{$self->{data}};
}

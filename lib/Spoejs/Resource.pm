package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.3 2004/03/04 03:43:26 snicki Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.3 $';

sub _initialize {
    my $self = shift;
    my $path = $ENV{DOCUMENT_ROOT} || '';
    $self->SUPER::_initialize( @_, 
			       full_path => "$path../lib/resource.txt" );
}

# Generate list of languages.
sub lang_list {
  my($self) = @_;

  # Read in resource file
  $self->get() unless $self->{data};

  # All two letter keys are languages.
  return sort grep /^..$/, keys %{$self->{data}};
}

package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.2 2004/03/03 08:26:25 sauber Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, 
		      full_path => "$ENV{DOCUMENT_ROOT}/../lib/resource.txt" );
}

# Generate list of languages.
sub lang_list {
  my($self) = @_;

  # Read in resource file
  $self->get() unless $self->{data};

  # All two letter keys are languages.
  return sort grep /^..$/, keys %{$self->{data}};
}


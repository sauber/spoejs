package Spoejs::Resource;
use base ( "Spoejs::Text" );

# $Id: Resource.pm,v 1.4 2004/03/04 07:36:10 sauber Exp $
$Spoejs::Resource::VERSION = $Spoejs::Resource::VERSION = '$Revision: 1.4 $';

sub _initialize {
    my $self = shift;
    $self->{file} = "resource.txt";
}

# Generate list of languages.
sub lang_list {
  my($self) = @_;

  # Read in resource file
  $self->_check_load();

  # All two letter keys are languages.
  return sort grep /^..$/, keys %{$self->{data}};
}

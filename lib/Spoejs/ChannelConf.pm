package Spoejs::ChannelConf;
use base ( "Spoejs", "Spoejs::Text" );

# $Id: ChannelConf.pm,v 1.1 2004/02/26 05:43:26 snicki Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.1 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}


# Static function - doesn't need initialized object
# Text.pm pt. depends on that
#
sub site_dir
{
    my $site_dir = $ENV{REQUEST_URI};

    $site_dir =~ s/(\/\w+\.html)$//;

    return $ENV{DOCUMENT_ROOT} . "users" . $site_dir;
}

1;

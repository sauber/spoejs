package Spoejs::ChannelConf;
use base ( "Spoejs", "Spoejs::Text" );

# $Id: ChannelConf.pm,v 1.2 2004/02/27 06:51:26 snicki Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}


# Static function - doesn't need initialized object
# Text.pm pt. depends on that
#
sub channel_dir
{
    my $dir = $ENV{REQUEST_URI};
    my $root = $ENV{DOCUMENT_ROOT};

    # For testing purposes outside apache env.
    $root ||= "/usr/local/wwwdoc/spoejs/htdocs/";
    $dir  ||= "/test";

    $dir =~ s/(\/\w+\.html)$//;

    return $root . "users" . $dir;
}

1;

package Spoejs::ChannelConf;
use base ( "Spoejs::Text" );

# $Id: ChannelConf.pm,v 1.4 2004/03/09 01:42:13 snicki Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.4 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}


# Static function - doesn't need initialized object
# Text.pm pt. depends on that
#
#sub channel_dir
#{
#    my $root = $ENV{DOCUMENT_ROOT};

    # For testing purposes outside apache env.
#    $root ||= "/usr/local/wwwdoc/spoejs/htdocs/";


#    return $root . "users" . user_dir();
#}

# 
#
sub channel_dir {
    my $self = shift;
    @dirs = reverse split /\//, $self->{path}; 
    return $dirs[0];
}

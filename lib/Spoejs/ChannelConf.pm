package Spoejs::ChannelConf;
use base ( "Spoejs::Text" );

# $Id: ChannelConf.pm,v 1.5 2004/03/12 07:13:37 snicki Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.5 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}


# 
#
sub channel_dir {
    my $self = shift;
    @dirs = reverse split /\//, $self->{path}; 
    return $dirs[0];
}

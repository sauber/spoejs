package Spoejs::ChannelConf;
use base ( "Spoejs::Text" );

# $Id: ChannelConf.pm,v 1.6 2004/04/09 17:18:38 sauber Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.6 $';

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

__END__
                                                                                
=head1 NAME
                                                                                
Spoejs::ChannelConf - Configuration of a channel
                                                                                
=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

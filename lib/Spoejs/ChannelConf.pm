package Spoejs::ChannelConf;
use base ( "Spoejs::Text" );
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

# $Id: ChannelConf.pm,v 1.8 2004/06/04 11:33:46 snicki Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.8 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}

# "Intercept" and encrypt password
sub set {
    my $self = shift;
    my %params = @_;

    if ( defined $params{password} ) {
	$params{password} = md5_hex( $params{password} );
    }
    $self->SUPER::set( %params );
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

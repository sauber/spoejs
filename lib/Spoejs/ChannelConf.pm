package Spoejs::ChannelConf;
use base ( "Spoejs::Text" );
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

# $Id: ChannelConf.pm,v 1.11 2004/08/08 12:10:31 snicki Exp $
$Spoejs::ChannelConf::VERSION = $Spoejs::ChannelConf::VERSION = '$Revision: 1.11 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}

# Make special processing on various attributes
sub shortname {
    my $self = shift;

    my $sn;
    $self->{path} =~ m|/(\w+?)/?$| and $sn = $1;
    return $sn;
}


# Make special processing on various attributes
sub set {
    my $self = shift;
    my %params = @_;

    if ( defined $params{password} ) {
	$params{password} = md5_hex( $params{password} );
    }

    if ( defined $params{shortname} ) {
	delete $params{shortname};
	warn 'Setting/changing of shortname is not allowed!';
    }

    $self->SUPER::set( %params ) or return undef;

    return 1;
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

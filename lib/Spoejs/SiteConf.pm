package Spoejs::SiteConf;
use Spoejs::Text;
use base ( "Spoejs::Text" );
use Data::Dumper;

# $Id: SiteConf.pm,v 1.3 2004/03/15 11:38:50 snicki Exp $
$Spoejs::SiteConf::VERSION = $Spoejs::SiteConf::VERSION = '$Revision: 1.3 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}


# Static function - doesn't need initialized object
# Text.pm pt. depends on that
#
sub site_dir
{
    my $site_dir = $ENV{SCRIPT_FILENAME};

    $site_dir =~ s/(\/\w+\.html)$//;

    return $site_dir;
}

1;

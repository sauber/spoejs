package Spoejs::SiteConf;
use Spoejs::Text;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: SiteConf.pm,v 1.2 2004/02/26 04:09:19 snicki Exp $
$Spoejs::SiteConf::VERSION = $Spoejs::SiteConf::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    $self->{T} = Spoejs::Text->new( file => 'settings.txt' );
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

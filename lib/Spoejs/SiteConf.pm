package Spoejs::SiteConf;
use base ( "Spoejs" );

sub site_dir
{
    my $self = shift;
    my $site_dir = $ENV{SCRIPT_FILENAME};

    $site_dir =~ s/(\/\w+\.html)$//;

    return $site_dir;
}

1;

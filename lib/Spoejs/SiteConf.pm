package Spoejs::SiteConf;
use Spoejs::Text;
use base ( "Spoejs::Text" );
use Data::Dumper;

# $Id: SiteConf.pm,v 1.4 2004/03/15 11:40:10 snicki Exp $
$Spoejs::SiteConf::VERSION = $Spoejs::SiteConf::VERSION = '$Revision: 1.4 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}

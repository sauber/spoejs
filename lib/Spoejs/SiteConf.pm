package Spoejs::SiteConf;
use Spoejs::Text;
use base ( "Spoejs::Text" );
use Data::Dumper;

# $Id: SiteConf.pm,v 1.5 2004/04/09 17:18:39 sauber Exp $
$Spoejs::SiteConf::VERSION = $Spoejs::SiteConf::VERSION = '$Revision: 1.5 $';

sub _initialize {
    my $self = shift;
    $self->SUPER::_initialize(@_, file => 'settings.txt' );
}

__END__

=head1 NAME
                                                                                
Spoejs::SiteConf - Configuration of policy, password etc. for website

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

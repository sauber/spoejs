package Spoejs::Lang;
use base ( "Spoejs" );
use utf8;
use Locale::Language;
use Data::Dumper;

# $Id: Lang.pm,v 1.2 2004/03/01 10:48:48 snicki Exp $
$Spoejs::Lang::VERSION = $Spoejs::Lang::VERSION = '$Revision: 1.2 $';

sub _initialize {
    my $self = shift;
    @{ $self->{langs} } = @_;

}

# Reduce input hash to desired language
#
sub tr {
    my $self = shift;
    my $data = shift;
    my ($key, $val);

    # Loop through outer hash elements
    while ( ($key, $val) = each %{ $data } ) {
	
	# Nested hash?
	if ( ref( $val ) eq 'HASH' ) {

	    # Find desired lang in subhash and move one level up
	    for ( @{ $self->{langs} } ) {
		if ( defined $data->{$key}->{$_} ) {
		    $data->{$key} = $data->{$key}->{$_};
		    last;
		}
	    } 

	    # If no lang was found, take first available
	    if ( ref($data->{$key}) eq 'HASH' ) {
		@vals = values %{$data->{$key}};
		$data->{$key} = $vals[0];
	    }

	} else {
	    
	    # Single value - find desired lang
	    for ( @{ $self->{langs} } ) {
		return $data->{$_} if defined $data->{$_};
	    }
	    
	    # If no desired lang available, return first
	    @vals = values %{$data};
	    return $vals[0];

	}
    }
    
    return %{$data};
}

# Todo:
# 1. Get resource.txt location automatically
# 2. Get language list automatically
# 
sub lang_list {
    my $self = shift;
    my @twoletter = qw( en dk de fr se jp zh gr ar it );
    my $T = new Spoejs::Text(  lang=>$self, 
	            full_path => '/usr/local/wwwdoc/spoejs/lib/resource.txt' );
    my %langs = $T->get( @twoletter );

    return %langs;
}

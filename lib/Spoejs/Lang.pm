package Spoejs::Lang;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: Lang.pm,v 1.11 2004/04/09 17:18:39 sauber Exp $
$Spoejs::Lang::VERSION = $Spoejs::Lang::VERSION = '$Revision: 1.11 $';

sub _initialize { }

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
	    for ( @{ $self->{lang_order} } ) {
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

	    # Skip non-languag elements
	    next unless $key =~ /^..$/;

	    # Single value - find desired lang
	    for ( @{ $self->{lang_order} } ) {
		return $data->{$_} if defined $data->{$_};
	    }
	    
	    # If no desired lang available, return first
	    @vals = values %{$data};
	    return $vals[0];

	}
    }

    return %{$data};
}

__END__
                                                                                
=head1 NAME
                                                                                
Spoejs::Lang - Update and lookup translations

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

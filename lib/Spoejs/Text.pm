# Notes/Todos:
# 1. Consider new-line handling in parsing/storing routines. 
# 2. Better error-handling!!!

package Spoejs::Text;
use Storable qw( dclone );
use Carp::Assert;
use Spoejs::ChannelConf;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: Text.pm,v 1.6 2004/02/28 07:36:21 snicki Exp $
$Spoejs::Text::VERSION = $Spoejs::Text::VERSION = '$Revision: 1.6 $';


# Constructor
sub _initialize {

    my $self  = shift;
    my %param = (@_);

    # Get site_dir for current user
    $self->{path}        = Spoejs::ChannelConf->channel_dir() ."/$param{path}";
    $self->{story_path}  = $param{path};
    $self->{file}        = $param{file};
    $self->{full_path}   = "$self->{path}/$param{file}";
    $self->{lang}        = $param{lang};
    $self->{is_loaded}   = 0;
    $self->{is_modified} = 0;

    assert( $param{path} ne '' ) if DEBUG;
    assert( $param{file} ne '' ) if DEBUG;
}


#### Private helper functions ####

# Save report hash to file
my $store_data = sub {

    my $self = shift;
    my %data = %{$self->{data}}; #grab data for easier access
    open (FH, ">$self->{full_path}") or return undef;

    foreach $key ( keys( %data ) ) {
	
	print FH "<$key>\n";
	foreach $lang ( keys( %{ $data{$key} }) ) {
	    
	    $text = $data{$key}{$lang};

	    if( $text =~ /\n/ ) {
		
		print FH "<lang=$lang>\n";
		print FH "$data{$key}{$lang}\n";
		print FH "</lang>\n";
		
	    } else {
		
		print FH "<lang=$lang/>$text\n";
	    }
	}
	
	# If not a hash, add variable directly
	print FH "$data{$key}\n" unless ref $data{$key};
	
	print FH "</$key>\n\n";
    }

    close FH;
};


# Reads and parses xml-like file format.
# Overall idea is a small state-machine that keeps track of which tags
# we are in.
#
# Todo: 
# 1. Support single line: <anno><lang=dk>pic1.jpg: test</lang><anno>
#
my $read_data = sub {

    my $self = shift;

    open FH, "<$self->{full_path}" or return; #Return if file does'nt exist

    my $tag = "";
    my $lang = "";
    my $in_tag = 0;
    my $in_lang = 0;
    my $one_lang = 0;

    while ( <FH> ) {

	chomp;

	# One-line lang-tags
	if ( s/^<lang=(\w\w)\/>// and $lang = $1) {
	    $in_lang=1;
	    $one_lang=1;
	}

	# Start-tag
	if ( /^<(\w+)>$/ and $tag = $1 ) {
	    $in_tag = 1;
	    next;
	}

	# Start lang-tag
	if ( /^<lang=(\w\w)>$/ and $lang = $1 ) {
	    $in_lang = 1;
	    next;
	}

	# End-tag
	if ( /^<\/(\w+)>$/ and $1 eq $tag ) {
	    $in_tag = 0;
	    next;
	}

	# End lang-tag
	if ( /^<\/(\w+)>$/ and $1 eq "lang" ) {
	    $in_lang = 0;
	    next;
	}


	# Add data if we are in a lang-tag
	if ( $in_lang && $in_tag )
	{
	    # If data exists for this key we append new data.
	    # This is for multiline data in eg. fulltext.
	    if ( $self->{data}{$tag}{$lang} ) {
		$self->{data}{$tag}{$lang} .= "\n$_";
	    } else {
		$self->{data}{$tag}{$lang} = $_;
	    }
	    if ( $one_lang ) {
		$one_lang = 0;
		$in_lang  = 0;
	    }
	} else {
	    
	    # We have a tag without lang
	    $self->{data}{$tag} = $_ if ( $in_tag );
	}
    }

    close FH;
};


# Read file from disk if it is not already in memory 
#
my $check_load = sub {

    my $self = shift;

    if ( $self->{is_loaded} == 0 ) {
	$self->$read_data();
	$self->{is_loaded} = 1;
    }

};


#### Public interface ####

# Return desired values from memory. If data not loaded from disk do so first.
#
sub get {

    my $self = shift;
    my %res;

    $self->$check_load();

    # Return only requested values if a list is supplied. dclone deep-copies
    if ( @_ == 1 ) {
	$val = shift;
 	# Get var incl. languages
	if ( ref $self->{data}{$val} ) {

	    $res{$val} = dclone( $self->{data}{$val} );

	} else {
	    $res{$_} = $self->{data}{$_[0]};
	}
	
 	$self->{lang}->tr( \%res );
 	return $res{$val};
    }
    elsif ( @_ > 1 ) {
	# Copy value for each argument
	for (@_) {

	    if ( ref $self->{data}{$_} ) {
		$res{$_} = dclone( $self->{data}{$_} );
	    } else {
		$res{$_} = $self->{data}{$_};
	    }
	}
    } else {
	# Copy whole data-hash	
	%res = %{ dclone( $self->{data} ) };
    }

    return defined $self->{lang} 
    ? $self->{lang}->tr( \%res )
    : %res;
}


# Add/update data. 
#
sub set {

    my $self = shift;

    $self->$check_load();

    %in_data = @_;

    # Loop through outer elements
    foreach $key ( keys %in_data ) {
	my $type = ref( $in_data{$key} );
	
	# If hash, loop again
	if ( $type eq "" ) {
	    # If SCALAR, ref is false - add/overwrite directly
	    $self->{data}{$key} = $in_data{$key};
	    
	} else {
	    # If this level contains nested elements they will be replaced
	    # TODO: Check and report nested elements og make funktion recursive
	    # to handle "unlimited" nesting.
	    if( defined $self->{data}{$key} ) {
		%{ $self->{data}{$key} } = ( %{ $self->{data}{$key} }, 
					     %{ $in_data{$key} } );
	    } else {
		%{ $self->{data}{$key} } = ( %{ $in_data{$key} } );
	    }
	}
    }

    $self->{is_modified} = 1;
}


# Delete story by removing it from memory and disk.
#
sub del {

    my $self = shift;

    delete( $self->{data} );

    $msg = unlink $self->{full_path};

    $self->{is_loaded} = 0;
    $self->{is_modified} = 0;
}


# Save data to disk when object is destroyed
sub DESTROY {

    my $self = shift;
    $self->$store_data( @_ ) if $self->{is_modified};
}

1;

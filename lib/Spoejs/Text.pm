# Notes/Todos:
# 1. Consider new-line handling in parsing/storing routines. 
# 2. Better error-handling!!!

package Spoejs::Text;
use Storable qw( dclone );
use Carp::Assert;
use Spoejs::ChannelConf;
use base ( "Spoejs" );
use Data::Dumper;

# $Id: Text.pm,v 1.26 2004/06/04 11:43:07 snicki Exp $
$Spoejs::Text::VERSION = $Spoejs::Text::VERSION = '$Revision: 1.26 $';


# Constructor
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );

    # Check file
    if ( -f "$self->{path}/$self->{file}" ) {
	$self->{msg} = "Can't write file $self->{path}/$self->{file}"
	    unless -w "$self->{path}/$self->{file}";
	$self->{msg} = "Can't read file $self->{path}/$self->{file}"
	    unless -r "$self->{path}/$self->{file}";
    } else {
	open FH, ">$self->{path}/$self->{file}"
	    or $self->{msg} = "Can't create $self->{path}/$self->{file}: $1";
	close FH;
    }
}


#### Private helper functions ####

# Save report hash to file
# Todo: binmode utf8
#
sub _store_data {

    my $self = shift;
    my %data = %{$self->{data}}; #grab data for easier access
    my $entry;
    my $subentry;

    open (FH, ">$self->{path}/$self->{file}") or
 	return $self->_err( "Could not open $self->{path}/$self->{file}: $!");

    foreach $key ( sort keys( %data ) ) {

	$entry = "<$key>\n";

	$subentry = '';
	foreach $lang ( sort keys( %{ $data{$key} }) ) {

	    next unless length $data{$key}{$lang} > 0;

	    $text = $data{$key}{$lang};

	    if( $text =~ /\n/ ) {
		
		$subentry .= "<lang=$lang>\n";
		$subentry .= "$text\n";
		$subentry .= "</lang>\n";
		
	    } else {
		
		$subentry .= "<lang=$lang/>$text\n";
	    }
	}
	
	# If not a hash, add variable directly
	$subentry .= "$data{$key}\n" unless ref $data{$key};
	
	$entry .= $subentry . "</$key>\n\n";

	print FH $entry if length $subentry > 0;
    }

    close FH;

    # Success
    return 1;
};


# Reads and parses xml-like file format.
# Overall idea is a small state-machine that keeps track of which tags
# we are in.
#
# Todo: 
# 1. Support single line: <anno><lang=dk>pic1.jpg: test</lang><anno>
# 2. skip whitespace
sub _read_data {

    my $self = shift;
    # Return here if file does not exist. 
    open FH, "<$self->{path}/$self->{file}" or 
 	return $self->_err( "Could not open $self->{path}/$self->{file}: $! ");

    my $tag = "";
    my $lang = "";
    my $in_tag = 0;
    my $in_lang = 0;
    my $one_lang = 0;

    my $kw_pattern = '[\w\.]';

    while ( <FH> ) {

	# One-line lang-tags
	if ( s/^\s*<lang=(\w\w)\/>// and $lang = $1) {
	    $in_lang=1;
	    $one_lang=1;
	}

	# Start-tag
	if ( /^<($kw_pattern+?)>$/ and $tag = $1 ) {
	    $in_tag = 1;
	    next;
	}

	# Start lang-tag
	if ( /^\s*<lang=(\w\w)>$/ and $lang = $1 ) {
	    $in_lang = 1;
	    next;
	}

	# End-tag
	if ( /^<\/($kw_pattern+?)>$/ and $1 eq $tag ) {
	    chomp $self->{data}{$tag};
	    $in_tag = 0;
	    next;
	}

	# End lang-tag
	if ( /^<\/(\w+)>$/ and $1 eq "lang" ) {
	    chomp $self->{data}{$tag}{$lang};
	    $in_lang = 0;
	    next;
	}


	# Add data if we are in a lang-tag
	if ( $in_lang && $in_tag )
	{
	    # If data exists for this key we append new data.
	    # This is for multiline data in eg. fulltext.
	    if ( defined $self->{data}{$tag}{$lang} ) {
		$self->{data}{$tag}{$lang} .= $_;
	    } else {
		$self->{data}{$tag}{$lang} = $_;
	    }
	    if ( $one_lang ) {
		chomp $self->{data}{$tag}{$lang};
		$one_lang = 0;
		$in_lang  = 0;
	    }
	} elsif ( $in_tag ) {
	    
	    # We have a tag without lang
	    if ( defined $self->{data}{$tag} ) {
		$self->{data}{$tag} .= $_; 
	    } else {
		$self->{data}{$tag} = $_;
	    }
	}
    }
    close FH;

    # Success
    return 1;
}



# Read file from disk if it is not already in memory 
#
sub _check_load {

    my $self = shift;

    unless ( defined $self->{is_loaded} ) {
	if ( -w "$self->{path}/$self->{file}" ) {
	    $self->_read_data() or return undef;
	    $self->{is_loaded} = 1;
	}
	else {
	    return $self->_err( "$self->{path}/$self->{file} is unwriteable" );
	}
    }

    # Success
    return 1;
}


#### Public interface ####

# Return desired values from memory. If data not loaded from disk do so first.
#
sub get {

    my $self = shift;
    my %res;

    $self->_check_load() or return undef;

    return $self->_err( "No data set or loaded" ) unless defined $self->{data};

    # Return only requested values if a list is supplied. dclone deep-copies
    if ( @_ == 1 ) {
	$val = shift;
 	# Get var incl. languages
	if ( ref $self->{data}{$val} ) {
	    # $val contains langs, so deep-copy
	    $res{$val} = dclone( $self->{data}{$val} );
	    %res = defined $self->{lang} ? $self->{lang}->tr( \%res ) : %res;
	    return $res{$val};
	} else {
	    # No langs so return value
	    return $self->{data}{$val};
	}
    }
    elsif ( @_ > 1 ) {

	# Copy value for each argument
	for my $kw (@_) {

	    if ( ref $self->{data}{$kw} ) {
		$res{$kw} = dclone( $self->{data}{$kw} );
	    } else {
		$res{$kw} = $self->{data}{$kw};
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

    $self->_check_load() or return undef;

    %in_data = @_;

    # Loop through outer elements
    foreach $key ( keys %in_data ) {
	my $type = ref( $in_data{$key} );
	
	if ( $type eq "" ) {
	    # If SCALAR, ref is false - add/overwrite directly

	    unless( $self->{data}{$key} && 
		    $self->{data}{$key} eq $in_data{$key} ) {
		$self->{data}{$key} = $in_data{$key};
		$self->{is_modified} = 1;
	    }
	    
	} else {
	    # If this level contains nested elements they will be replaced
	    # TODO: Check and report nested elements og make funktion recursive
	    # to handle "unlimited" nesting.
	    # TODO: Set is_modified only if something really changes.
	    if( defined $self->{data}{$key} ) {
		%{ $self->{data}{$key} } = ( %{ $self->{data}{$key} }, 
					     %{ $in_data{$key} } );
		$self->{is_modified} = 1;

	    } else {
		%{ $self->{data}{$key} } = ( %{ $in_data{$key} } );
		$self->{is_modified} = 1;
	    }
	}
    }

    # Success
    return 1;
}


# Delete file by removing it from memory and disk.
#
sub del {

    my $self = shift;

    delete( $self->{data} );
    my $file =  $self->{path} . '/' . $self->{file};
    $msg = unlink $file;

    delete $self->{is_loaded};
    delete $self->{is_modified};

    return $msg > 0 ? 1 : $self->_err( "Could not delete file" );
}


# Save data to disk when object is destroyed
sub DESTROY {

    my $self = shift;
    $self->_store_data( @_ ) if defined $self->{is_modified};
}

__END__
                                                                                
=head1 NAME
                                                                                
Spoejs::Text - Generic module for handling text files. Supports text in multiple languages.

=head1 LICENSE
                                                                                
Artistic License
http://www.opensource.org/licenses/artistic-license.php
                                                                                
=cut

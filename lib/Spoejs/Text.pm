# Notes/Todos:
# 1. Consider new-line handling in parsing/storing routines. 
# 2. Better error-handling!!!

package Spoejs::Text;
use Storable qw( dclone );
use Spoejs::ChannelConf;
use base ( "Spoejs" );
use YAML qw( DumpFile LoadFile);

# $Id: Text.pm,v 1.35 2004/08/08 16:51:42 snicki Exp $
$Spoejs::Text::VERSION = $Spoejs::Text::VERSION = '$Revision: 1.35 $';


# Constructor
sub _initialize {

    my $self  = shift;
    %{$self} = ( %{$self}, @_ );

}


#### Private helper functions ####

#
#
sub _store_data {

    my $self = shift;

    # Keep three backups of old versions
    rename "$self->{path}/$self->{file}.1", "$self->{path}/$self->{file}.2"
     if -s "$self->{path}/$self->{file}.1";
    rename "$self->{path}/$self->{file}.0", "$self->{path}/$self->{file}.1"
     if -s "$self->{path}/$self->{file}.0";
    rename "$self->{path}/$self->{file}", "$self->{path}/$self->{file}.0"
     if -s "$self->{path}/$self->{file}";

    local $YAML::UseVersion = 0; # Avoid cluttering files with version info
    DumpFile( "$self->{path}/$self->{file}", $self->{data} );

    # Success
    return 1;
};


#
#
sub _read_data {

    my $self = shift;

    eval{$self->{data} = LoadFile( "$self->{path}/$self->{file}" );};
    if ($@) { 
	my @msgs = split /\n/, $@;
	my $msg ="$self->{path}/$self->{file}:\n$msgs[2]\n$msgs[3]";
	warn $msg;
	return $self->_err( $msg );
    }
    
    # Success
    return 1;
}



# Read file from disk if it is not already in memory 
#
sub _check_load {

    my $self = shift;

    unless ( defined $self->{is_loaded} or defined $self->{is_savable} ) {
	if ( -f "$self->{path}/$self->{file}" ) {
	    $self->_read_data() or return undef;
	    $self->{is_loaded} = 1;
        }
    }

    # Success
    return 1;
}

# Check if a file can be created for saving data
#
sub _check_save {
  my $self = shift;

  return 1 if $self->{is_savable};

  # Check if file already exists and is writable
  if ( -e "$self->{path}/$self->{file}" ) {
    if ( -w "$self->{path}/$self->{file}" ) {
      $self->{is_savable} = 1;
      return 1;
    } else {
      return $self->_err( "$self->{path}/$self->{file} is not writable" );
    }
  }

  # Otherwise check if dir exists and is writable
  if ( -e $self->{path} ) {
    if ( -w $self->{path} ) {
      $self->{is_savable} = 1;
      return 1;
    } else {
      return $self->_err( "$self->{path} is not writable" );
    }
  } else {
    return $self->_err( "$self->{path} doesn't exist" );
  }
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

    $self->_check_load();
    $self->_check_save() or return undef;

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

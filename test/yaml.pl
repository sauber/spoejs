#!/usr/bin/perl -w -I../lib

use Spoejs::Text;
use YAML qw(DumpFile);
use File::Find;

my $path = $ARGV[0] || '../htdocs/users';

my @paths;
find ( { wanted => sub {
    push (@paths, [ $File::Find::dir, $_ ] );
}, follow_fast => 1 }, $path );

for (@paths) {
    next unless old_format( "$_->[0]/$_->[1]" );
    convert( $_->[0], $_->[1] );
}

sub convert {
    my ( $path, $file ) = @_;
    my $T = Spoejs::Text->new( path => $path, file => $file );
    return if error_check( $T );
    my %res = $T->get();
    return if error_check( $T );
    DumpFile( "$path/$file", \%res );
}

sub old_format {
    my $path = shift;
    my $ext = '.txt';
    my $fl;

    return undef unless $path =~ /$ext$/;
    
    open (FH, "<$path") or die "Err: $!";
    $fl = <FH>;
    close FH;
    return undef unless $fl;

    # Simple detection of old file format
    if ( $fl =~ /<(.*)?>/g ) {
	return 1;
    } else {
	return undef;
    }
}

sub error_check {
    my $obj = shift;

    if ( defined $obj->{msg} ) {
	print "$obj->{msg}\n";
	return 1;
    }

    return undef;
}

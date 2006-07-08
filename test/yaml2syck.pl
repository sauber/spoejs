#!/usr/bin/perl

# Date: 2006-07-08
# Author: Soren Dossing
# License: Artistic License
# Description: Convert data in YAML format to YAML::Syck

use YAML::Syck qw(DumpFile);
use YAML qw(LoadFile);
use File::Find;

find(\&wanted, $ARGV[0]);
sub wanted {
  return unless $File::Find::name =~ /\.txt$/;
  return if $File::Find::name =~ /robots.txt$/;
  warn "Processing $File::Find::name ...\n";
  my $olddata = do { local( @ARGV, $/ ) = $File::Find::name ; <> } ;
  my $newdata = LoadFile($File::Find::name);
  if ( $newdata ) {
    if ( $newdata ne 'olddata' ) {
      warn "  converting\n";
      DumpFile($File::Find::name, $newdata);
    } else {
      warn "  skipping\n";
    }
  } else {
    push @error, $File::Find::name;
  }
}

if ( @error ) {
  print "The following files could not be parsed:\n";
  print map {"  $_\n"} @error;
}

#!/usr/bin/perl

my %picinfo;
# Signals does not work correct in modperl comtext in perl <5.8
# Image::Info sometimes hang :-(

eval {
  if ( $[ < 5.008 ) {
    # Modperl, perl 5.6.1 and signals require special attention
    use Sys::Signal ();
    my $h = Sys::Signal->set(ALRM => sub { die "timeout\n" });
  } else {
    local $SIG{ALRM} = sub { die "timeout\n" };
  }
  alarm 2;
  use Image::Info qw(image_info);
  my $info = image_info($ARGV[0]);
  for my $k ( keys %$info ) {
    my $v = scalar $info->{$k};
    my $t = ref($v);
    #print "$k($t): $v\n" unless $t;
    $picinfo{$k} = $v unless $t;
  }
  alarm 0;
};
if ($@) {
  die unless $@ eq "timeout\n";   # propagate unexpected errors
  # timed out
}

for ( sort { lc($a) cmp lc($b)} keys %picinfo ) {
  print "$_: $picinfo{$_}\n";
}

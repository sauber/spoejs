#!/usr/bin/perl

# Image::Info sometimes hang :-(
my %picinfo;
eval {
  local $SIG{ALRM} = sub { die "timeout\n" };
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

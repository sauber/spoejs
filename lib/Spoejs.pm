package Spoejs;

our $VERSION = '0.01';

use 5.006001;
use strict;
use warnings;

require Exporter;

# $Id: Spoejs.pm,v 1.6 2004/04/09 14:48:26 boinger Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.6 $';

# Constructor
#
sub new {

    my $invocant  = shift;
    my $class     = ref($invocant) || $invocant;

    my $self = { @_ };
    bless $self, $class;
    $self->_initialize();

    return $self;
}

# Default initializor
#
sub _initialize {}

# Write error messages to $self->{msg} and return undef
#
sub _err {
  my $self = shift;
  $self->{msg} = shift;
  return undef;
}

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Spoejs ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Spoejs - Perl module to support the Spoejs web project (an extensible, east to manage, photo-oriented blog system.  ANd then some.)


=head1 SYNOPSIS

  use Spoejs;

=head1 DESCRIPTION

The basic idea of Spoejs is an image-oriented blog/journal. Spoejs can be used not only for storing pictures, but also for journaling of stories in a diary style. Or a combination thereof.

There are web sites that allow you to upload one picture a day, or that allow you a limit quota. What we are writing is for larger volume picture collections. This project is geared more toward people with home networks or who otherwise admin their own personal servers.

We imagine the typical situation is a tech kid with his/her own Linux server(s) at home installing spoejs and letting family and friends post large picture collections from summer BBQ's, ski trips, parties, vacations and so on.

Since we are imagining this to be used not only by the tech kids themselves but also family and friends, this means that it should be easy to use for non-tech people. We intend the interface for uploading pictures, writing stories and annotations to have a very low learning curve. For those that need it, there'll also be basic photo editing options such as rotation, cropping and adjusting brightness.

Our choice of technology is Perl and Mason. We write .pm modules to control data, and write Mason code to embed data into HTML. We use a few Apache features. We run a squid cache in front of Apache for caching scaled pictures, etc. That way we don't have to do much caching inside Mason, improving performance.

Our data is stored as media and text files in the file system. We have a format for text files that looks like xml, but is easier to read and edit in a text editor. We have chosen this so that it is indeed to hand edit and to tar up to move to a different server if necessary.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Visit http://spoejs.sf.net/ for additional information on Spoejs.
Visit http://masonhq.com/ for additional information on Mason, the templating substructure of Spoejs.

=head1 AUTHOR

sauber, snicki, sondara, boinger, and others.

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.

=cut

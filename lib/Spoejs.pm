package Spoejs;

our $VERSION = '0.01';

use 5.006001;
use strict;
use warnings;

require Exporter;

# $Id: Spoejs.pm,v 1.10 2004/08/16 10:06:38 sauber Exp $
$Spoejs::VERSION = $Spoejs::VERSION = '$Revision: 1.10 $';

# Constructor
#
sub new {

    my $invocant  = shift;
    my $class     = ref($invocant) || $invocant;

    my $self = { @_ };
    bless $self, $class;

    # XXX: How do we remove this special case???
    my $tmp = $self->_initialize();
    $self = $tmp if (UNIVERSAL::isa($tmp, 'Spoejs::Media') );

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

# Generic check if a file can be created for saving data
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

# Create a Bootstring object
#
sub _create_bs {
  my($self) = shift;
  $self->{_BS} ||= new Bootstring( BASIC => ["a".."z", "A".."Z", "0".."9"],
                                   DELIMITER => '_',
                                   INITIAL_BIAS => 32,
                                   TMIN => 38,
                                   DAMP => 40,
                                   TMAX => 53,
                                   SKEW => 78,
                                 );
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

Spoejs - Perl module to support the Spoejs web project (an extensible,
east to manage, photo-oriented blog system.  And then some.)


=head1 SYNOPSIS

  use Spoejs;

=head1 DESCRIPTION

The basic idea of Spoejs is an image-oriented blog/journal.
Spoejs can be used not only for storing pictures, but also
for journaling of stories in a diary style. Or a combination
thereof.

There are web sites that allow you to upload one picture a
day, or that allow you a limit quota. What we are writing is
for larger volume picture collections. This project is geared
more toward people with home networks or who otherwise admin
their own personal servers.

We imagine the typical situation is a tech kid with his/her
own Linux server(s) at home installing spoejs and letting
family and friends post large picture collections from summer
BBQ's, ski trips, parties, vacations and so on.

Since we are imagining this to be used not only by the tech
kids themselves but also family and friends, this means that
it should be easy to use for non-tech people. We intend the
interface for uploading pictures, writing stories and
annotations to have a very low learning curve. For those
that need it, there'll also be basic photo editing options
such as rotation, cropping and adjusting brightness.

Our choice of technology is Perl and Mason. We write .pm
modules to control data, and write Mason code to embed data
into HTML. We use a few Apache features. We run a squid cache
in front of Apache for caching scaled pictures, etc. That way
we don't have to do much caching inside Mason, improving
performance.

Our data is stored as media and text files in the file system.
We have a format for text files that looks like xml, but is
easier to read and edit in a text editor. We have chosen this
so that it is indeed to hand edit and to tar up to move to a
different server if necessary.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Visit http://spoejs.sf.net/ for additional information on Spoejs.
Visit http://masonhq.com/ for additional information on Mason, the
templating substructure of Spoejs.

=head1 AUTHOR

snicki, mike, cangcang, boinger, & sauber

=head1 COPYRIGHT AND LICENSE

This program is released under the Artistic License.

=cut

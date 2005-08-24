package Spoejs::StoryList;
use base ( "Spoejs::List", "Spoejs" );
use Spoejs::ChannelConf;
use Spoejs::Story;
no Carp::Assert;
use Date::Manip;
use File::Path;

use Data::Dumper;

# ToDo:
# 1. Avoid sorting by Story::date() for all stories in 'count' limited lists

# Dir format yyyy/mm/## width ## 01-99 incrementing by 1 for each story.
#
# XXX: Desired functionality:
# add_story(), list_all_stories(), del_story()
# list_add_stories(category=>'sport')
# list_add_stories(author=>'soren')
# list_stories(start=>20, count=>10)
# list_stories(start=>20, count=>10, category=>'sport')
# next_story(cur=>'2004/02/01'); 
# prev_story(cur=>'2004/02/01', author=>'soren');


# $Id: StoryList.pm,v 1.44 2005/08/24 09:16:31 sauber Exp $
$Spoejs::StoryList::VERSION = $Spoejs::StoryList::VERSION = '$Revision: 1.44 $';

sub _initialize {
    my $self = shift;
    
    $self->{file} = "data.txt";
    $self->_check_dir();
}


#### Private helper functions ####

# Return references to all stories, sorted by date
#
sub _all_stories {

    my $self = shift;

    # Already loaded
    return if ( defined $self->{stories} );

    my $file = $self->{file};
    my $root_path = $self->{path};

    my @paths = $self->_list_from_filename( $root_path, $file );

    for my $p ( @paths ) {
	my $story = Spoejs::Story->new( path => $p, lang => $self->{lang} );

	# Generate index
	$story->{sortkey} = Date::Manip::ParseDate( $story->get( 'date' ) ) .
	                    '-' . $story->story_path_from_full();

 	push  @{$self->{stories}}, $story;
    }
};


# Sort list of Story objects according to date
#
sub _sort_by_date {

    my ( $self ) = @_;
    @{$self->{stories}} = sort { $b->{sortkey} cmp $a->{sortkey} } 
                      @{$self->{stories}};
}


#### Public interface ####

# Add story - creates dir-structure for new story
#
sub add_story {
    my $self = shift;
    my %input = @_;
    my $path = $self->{path};

    # Get year/month for folder or default to today
    my $date = $input{date} || localtime;
    my ($month, $year) = Date::Manip::UnixDate( $date, "%m", "%Y" );

    # Make sure folder exist
    $path = "$path/$year/$month";
    eval { mkpath($path) };
    if ($@) {
	return $self->_err( "Couldn't create $dir: $@" );
    }
    
    # Get counter, if exists
    my @current_dirs = $self->_dirs_in_path( $path );
 
    # Start from 0 if no dirs exist
    $current_dirs[0] ||= 0;    

    # Check overflow
    return $self->_err( "Too many stories in $path" ) if $current_dirs[0] > 98;

    # Compose new path
    $new_dir = sprintf "%s/%0.2d", $path, $current_dirs[0] + 1;

    mkdir $new_dir or return $self->_err( "Could not create dir $p: $!" );

    # Remove channel part of dir
    $new_dir =~ s/$self->{path}\///;

    # return path to new folder
    return $new_dir;
}


# Delete a story including all datafiles and media files
#
sub del_story {

    my $self = shift;
    my %in = @_;
    my $root_path = $self->{path};

    # Check given path
    return $self->_err( "Invalid path: $in{story}" ) 
	unless $in{story} =~ m!\d+/\d+/\d+$!;

    # Remove given story-dir
    my $res = rmtree "${root_path}/$in{story}";

    # XXX: Enhance to trap  $SIG{__WARN__}
    return $res > 0 ? $res : $self->_err( "Could not remove story" );
}


# Return the total number of stories
#
sub count {
    my $self = shift;

    # The list of paths to all data.txt files in scalar context is the count
    return scalar $self->_list_from_filename( $self->{path}, $self->{file} );
}

# Count number of stories by keyword
# XXX: Should renamed to e.g. count_stories_by, number_of etc..
sub count_stories {
  my $self = shift;
  my %in = @_;
  my %counts;

  # Load story array
  $self->_all_stories();

  if ( $in{by} eq 'category' or  $in{by} eq 'author' ) {
    for my $s ( @{$self->{stories}} ) {
      next if !defined $in{include_inactive} && $s->get('active') eq 'no';
      my $cat = $s->get( $in{by} );
      $counts{$cat}++;
    }
    return %counts;    
  }
}


sub hide_inactive {
   my $self = shift;
   $self->{show_inactive} = undef;
}


sub show_inactive {
   my $self = shift;
   $self->{show_inactive} = 1;
}


# List stories based on given keywords
# Overall ideas is to get full list and remove based on given criterias
#
sub list_stories {

    my $self = shift;
    my %in = @_;

    # Extract count if given; undef for all stories
    $list_count = $in{count} || undef;
    delete $in{count};

    # Get story array
    $self->_all_stories(); # Load story array
    $self->_sort_by_date();

    my @res = @{$self->{stories}};

    # Convert story_num to story
    if ( defined $in{story_num} ) {
      $in{story} = $res[$in{story_num}];
      $in{story} = $in{story}->story_path_from_full() if defined $in{story};
      delete $in{story_num};
    }

    # Extract other params
    my $story = $in{story};
    delete $in{'story'};
    my $prev = $in{'prev'};
    delete $in{'prev'};
    my $next = $in{'next'};
    delete $in{'next'};
    my $from = $in{from};
    delete $in{from};
    my $to = $in{to};
    delete $in{to};

    # Filter inactive
    $in{active} = 'yes' unless $self->{show_inactive};

    # Filter by away stories where keywords don't match
    if ( keys %in > 0 ) {
      my @new;
      foreach $story ( @res ) {
        my $add = 1;
        for $kw ( keys %in ) {
          if ( defined $in{$kw} ) {
	    my $story_kw = $story->get( $kw );
	    $story_kw ||= 'yes' if $kw eq 'active'; # Special case
            undef $add if $story_kw and $story_kw ne $in{$kw};
            last unless $add;
          }
        }
	push @new, $story if $add;
      }
      @res = @new;
    }

    # Handle 'story' separately
    if ( $story ) {
	my $story_dir = $story;
	$story_dir =~ s/\///g;

        # Get story date
        my $S = new Spoejs::Story( path => "$self->{path}/$story", 
				   lang => $self->{lang} );

	my $sortkey = Date::Manip::ParseDate( $S->get( 'date' ) ) .
	              '-' . $story;

        # Remove entries newer than sortkey and truncate to given count
	if ( $prev ) {
	    @res = grep { $_->{sortkey} <= $sortkey } @res;
	    $#res = $prev-1 if $prev-1 < $#res;
	}

	# Remove entries older than sortkey and truncate
	if ( $next ) {
	    @res = grep { $_->{sortkey} >= $sortkey } reverse @res;
	    $#res = $next if $next < $#res;
	}
    } 

    # Handle "from-to" date range separately    
    if ( $from or $to ) {
	my $froml = $from || 0;
	$froml =~ s/\///g;
	# XXX: What happens after 99 stories in december 9999?
	my $tol = $to || 99991299;
	$tol =~ s/\///g;

	@res = grep { $_[0] >= $from1 and $_[0] <= to1 } @res;
    } 

    # Shrink array to 'count' elements
    $#res = $list_count - 1 if $list_count and @res > $list_count;

    return @res;
}


sub list {
    my $self = shift;
    return $self->list_stories();
}


# Move story to directory corresponding to date
#
sub fix_dir_date {
    my $self = shift;
    my $story_path = shift;

    # Check given path
    $story_path =~ s!/*?!!;
    return $self->_err( "Invalid path: $story_path" ) 
	unless $story_path =~ m!\d+/\d+/\d+$!;

    # Read in Story
    my $S = new Spoejs::Story( path => "$self->{path}/$story_path",
			       lang => $self->{lang} ) or return undef;

    # Get story date
    my $date = $S->get( 'date' );

    #Check if we need to change
    my ($month, $year) = Date::Manip::UnixDate( $date, "%m", "%Y" );

    # Only continue if we can read the date from the story
    return $self->_err( "Invalid path: $year/$month" ) 
	unless "$year/$month" =~ m!\d\d\d\d/\d\d$!;

    return $story_path 
	if ( substr("$year/$month",0,7) eq substr($story_path,0,7) );

    # Create new story dir
    my $new_path = $self->add_story( date => $date );
    $new_path =~ s!/*?!!;

    # Check new path
    return $self->_err( "Invalid path: $new_path" ) 
	unless $new_path =~ m!\d+/\d+/\d+$!;

    # Move old storydir on top of newly created dir
    rename "$self->{path}/$story_path", "$self->{path}/$new_path";

    $S = undef; # Make sure we dont touch story after deleting it below
    $self->del_story( $story_path );

    return $new_path;
}

__END__

=head1 NAME

Spoejs::StoryList - List, insert, edit or delete stories

=head1 LICENSE

Artistic License
http://www.opensource.org/licenses/artistic-license.php

=cut

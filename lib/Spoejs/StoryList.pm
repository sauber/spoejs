package Spoejs::StoryList;
use base ( "Spoejs" );
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


# $Id: StoryList.pm,v 1.13 2004/03/06 06:48:42 snicki Exp $
$Spoejs::StoryList::VERSION = $Spoejs::StoryList::VERSION = '$Revision: 1.13 $';

sub _initialize {
    my $self = shift;

    $self->{file} = "data.txt";
}


#### Private helper functions ####

# Return references to all stories, sorted by date
#
sub _all_stories {

    my $self = shift;
    my @stories;
    my $file = $self->{file};
    my $root_path = $self->{path};

    use File::Find;
    find sub {
	my $res = $File::Find::name if /$file$/;
	return unless $res;
	$res =~ s/\/$file//;      #Strip filename

	my $S = Spoejs::Story->new( path => $res, lang => $self->{lang} );

	# XXX: Why is a get() necesary here?
	$S->get( );

	push @stories, $S;
    },
    $root_path;

    return @stories;
};


sub _sort_by_date {

    my ( $self, @stories ) = @_;

    @sorted_stories = map { $_->[0] } 
                      sort { $b->[1] <=> $a->[1] } 
                      map { [$_,
			     Date::Manip::UnixDate( $_->get( 'date' ), '%s') 
			     ] } 
                      @stories;

    return @sorted_stories;
}

sub _ls_loop {
    my ( $self, $count, $comp, @all ) = @_;
    
    my @new;
    foreach $story ( @all ) {

	my $path = $story->story_path_from_full();
	$path =~ s/\///g;

	if ( $comp->( $path ) ) {
	    push @new, $story;
	    last if --$count == 0;
	}
    }
    return @new;
};


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
    mkdir "$path/$year" unless -d "$path/$year";
    mkdir "$path/$year/$month" unless -d "$path/$year/month";
    $path = "$path/$year/$month";

    # Get counter, if exists
    opendir DH, "$path";
    my @current_dirs = sort { $b <=> $a }
                       grep { -d "$path/$_" }
                       grep !/^\./,
                       readdir DH;
    closedir DH;

    # Start from 0 if no dirs exist
    $current_dirs[0] ||= 0;    

    return undef if $current_dirs[0] > 98;

    $new_dir = sprintf "%s/%0.2d", $path, $current_dirs[0] + 1;

    mkdir $new_dir;

    # Remove channel part of dir
    $new_dir =~ s/$self->{path}\///;

    # return path to new folder
    return $new_dir;
}


sub del_story {

    my $self = shift;
    my %in = @_;
    my $root_path = $self->{path};

    # Remove given story-dir
    rmtree "${root_path}/$in{story}";
}

# XXX: Add counts by year/month
#
sub count_stories {
    my $self = shift;
    my %in = @_;
    my %counts;

    # Get story array
    @all = $self->_all_stories();

    if ( $in{by} eq 'category' or  $in{by} eq 'author' ) {
	for ( @all ) {
	    my $cat = $_->get( $in{by} );
	    $counts{$cat}++;
	}
	return %counts;    
    }
    
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
    my @res = $self->_sort_by_date( $self->_all_stories() );

    # Return all stories if no keyword/story is given
    if ( keys %in == 0 ){ }

    # Handle 'story' separately
    if ( $in{story} ) {
	my $story_dir = $in{story};
	$story_dir =~ s/\///g;
	
	@res = $self->_ls_loop( $in{'prev'}, 
			       sub { return $_[0] < $story_dir; },
			       @res ) if $in{'prev'}; 
	
	@res = $self->_ls_loop( $in{'next'}, 
			       sub { return $_[0] > $story_dir; },
			       reverse @res ) if $in{'next'};
	
	delete $in{'story'};
	delete $in{'prev'};
	delete $in{'next'};
    } 
    
    # Handle "from-to" date range separately    
    if ( $in{from} or $in{to} ) {
	my $from = $in{from} || 0;
	$from =~ s/\///g;
	# XXX: What happens after 99 stories in december 9999?
	my $to = $in{to} || 99991299;
	$to =~ s/\///g;

	@res = $self->_ls_loop( -1,
			       sub { return $_[0] >= $from and $_[0] <= $to; },
			       @res ); 
	
	delete $in{from};
	delete $in{to};
    } 
    
    if ( keys %in > 0 ) {
	# Filter by keyword, if given
	my @kw = keys %in;
	my $kw = $kw[0];
	
	my @new;
	foreach $story ( @res ) {
	    my $story_kw = $story->get( $kw );
	    push @new, $story if ( $story_kw eq $in{$kw} );
	}

	@res = @new;	
    }

    # Shrink array to 'count' elements
    $#res = $list_count - 1 if $list_count and @res > $list_count;

    return @res;
}

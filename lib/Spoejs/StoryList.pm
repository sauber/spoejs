package Spoejs::StoryList;
use base ( "Spoejs" );
use Spoejs::ChannelConf;
use Spoejs::Story;
no Carp::Assert;
use Date::Manip;
use Data::Dumper;

# Dir format yyyy/mm/## width ## 01-99 incrementing by 1 for each story.
#
# add_story(), list_all_stories(), del_story()
# list_add_stories(category=>'sport')
# list_add_stories(author=>'soren')
# list_stories(start=>20, count=>10)
# list_stories(start=>20, count=>10, category=>'sport')
# next_story(cur=>'2004/02/01'); 
# prev_story(cur=>'2004/02/01', author=>'soren');


# $Id: StoryList.pm,v 1.1 2004/02/27 06:47:01 snicki Exp $
$Spoejs::StoryList::VERSION = $Spoejs::StoryList::VERSION = '$Revision: 1.1 $';

sub _initialize {
    my $self = shift;
    my %input = @_;

    $self->{channel_path} = Spoejs::ChannelConf->channel_dir();
    $self->{file} = "data.txt";
    $self->{lang} = $input{lang};
}


#### Private helper functions ####

# Return references to all stories, sorted by date
#
my $all_by_date = sub {

    my $self = shift;
    my @stories;
    my $file = $self->{file};
    my $root_path = $self->{channel_path};

    use File::Find;
    find sub {
	my $res = $File::Find::name if /$file/;
	return unless $res;
	$res =~ s/\/$file//;      #Strip filename
	$res =~ s/$root_path\///; #Strip leading path

	my $S = Spoejs::Story->new( path => $res, lang => $self->{lang} );

	my %date = $S->get( "date" );

	push @stories, $S;
    },
    $root_path;

    @sorted_stories = map { $_->[0] } 
                      sort { $b->[1] <=> $a->[1] } 
                      map { [$_,
			     Date::Manip::UnixDate( $_->date(), '%s') 
			     ] } 
                      @stories;

    return @sorted_stories;
};



#### Public interface ####

sub add_story {
    my $self = shift;
    my $path = $self->{channel_path};

    # Get year/month for folder
    my ($month, $year) = (localtime)[4,5];
    $month += 1;
    $year  += 1900;

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

    $new_dir = sprintf "%s/%0.2d", $path, $current_dirs[0] + 1;

    mkdir $new_dir;

    # Remove channel part of dir
    $new_dir =~ s/$self->{channel_path}\///;

    # return path to new folder
    return $new_dir;
}


sub del_story {

    my $self = shift;
    my %in = @_;
    my $root_path = $self->{channel_path};

    # Remove given story-dir
    system( "rm -rf ${root_path}/$in{story}" );
}


sub count_stories {
    my $self = shift;
    my %in = @_;

#    $self->$count_by_xxx() if ( $in{by} =~ /\w+/ );

}


sub list_stories {

    my $self = shift;
    my %in = @_;

    # Return all stories if no arguments given
    return $self->$all_by_date() if ( @_ < 1 );

}


### Switch
#     my $switch = { 'category' => sub { print "cat"; }, 
# 		   'author' => sub { print "auth"; }, 
# 		   'y' => sub { print ""; },
# 		   'q' => sub { exit; } };
    
#     $$switch{$_}(); # Call the anon. sub

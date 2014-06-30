#!/usr/bin/perl -w
use strict;
use Hammer;
use Hammer::Action::GetURI;
use Hammer::Stats;
use Getopt::Long;
use Data::Dumper;
use Storable;


my ($hostname, $thread_count, $flush, $maxdepth, $uri) = (undef, undef, 0, 999, undef);

GetOptions(
	"hostname=s" => \$hostname,
	"thread_count=i" => \$thread_count,
	"flush" => \$flush,
	"maxdepth=i" => \$maxdepth,
	"uri" => \$uri,
);

if ($hostname && $thread_count) {
	my $hammer = Hammer->new(
		protocol => 'http',
		hostname => $hostname,
		thread_count => $thread_count,
		flush => $flush,
		actions => [
			Hammer::Action::GetURI->new( name => 'Home Page', uri => '/'),
			Hammer::Action::GetURI->new( name => 'Lineups', uri => '/lineups'),
			Hammer::Action::GetURI->new( name => 'GrindersLive', uri => '/live'),
			Hammer::Action::GetURI->new( name => 'MLB Daily Batter Hub', uri => '/pages/Hot_Streak_Hitters-56970'),
		]
	);

	if ($uri) {
		$hammer->actions( Hammer::Action::GetURI->new(  name => 'Custom URI', uri => $uri  ) );
	}	
	$hammer->start;
	$hammer->wiki_report;
} else {
	usage();
}

sub usage {
	print "You must specific both a hostname and a thread_count\n";
}



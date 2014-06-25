#!/usr/bin/perl -w
use strict;
use Hammer;
use Hammer::Action::GetURI;
use Getopt::Long;
use Data::Dumper;

my ($hostname, $thread_count, $flush) = (undef, undef, 0);

GetOptions(
	"hostname=s" => \$hostname,
	"thread_count=i" => \$thread_count,
	"flush" => \$flush,
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
		]
	);
	
	$hammer->start;
	print Dumper($hammer->cache->get_hash);
} else {
	usage();
}

sub usage {
	print "You must specific both a hostname and a thread_count\n";
}



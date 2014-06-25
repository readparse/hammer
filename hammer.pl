#!/usr/bin/perl -w
use strict;
use Hammer;
use Hammer::Action::GetURI;
use Getopt::Long;

my ($hostname, $thread_count) = (undef, undef);

GetOptions(
	"hostname=s" => \$hostname,
	"thread_count=i" => \$thread_count,
);

if ($hostname && $thread_count) {
	my $hammer = Hammer->new(
		protocol => 'http',
		hostname => $hostname,
		thread_count => $thread_count,
		actions => [
			Hammer::Action::GetURI->new( name => 'Home Page', uri => '/'),
			#Hammer::Action::GetURI->new( name => 'Lineups', uri => '/lineups'),
		]
	);
	
	$hammer->start;
} else {
	usage();
}

sub usage {
	print "You must specific both a hostname and a thread_count\n";
}



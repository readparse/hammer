#!/usr/bin/perl -w
use strict;
use Hammer;
use Hammer::Action::GetURI;

my $hammer = Hammer->new(
	protocol => 'http',
	hostname => 'rotogrinders.com',
	thread_count => 10,
	actions => [
		Hammer::Action::GetURI->new( name => 'Home Page', uri => '/'),
		Hammer::Action::GetURI->new( name => 'Lineups', uri => '/lineups'),
	]
);

$hammer->start;


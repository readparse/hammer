#!/usr/bin/perl -w
use strict;
use Hammer;
use Hammer::Action::GetURI;

my $hammer = Hammer->new(
	protocol => 'http',
	hostname => 'clayton.rotogrinders.com',
	thread_count => 40,
	actions => [
		Hammer::Action::GetURI->new( name => 'API call', uri => '/projected-stats/all/daily?key=O5953iugLUcI9ddT3le1CN84glM1ZpsV&args[site_id]=2'),
		#Hammer::Action::GetURI->new( name => 'Lineups', uri => '/lineups'),
	]
);

$hammer->start;


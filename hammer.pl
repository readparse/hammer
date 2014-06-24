#!/usr/bin/perl -w
use strict;
use Hammer;

my $hammer = Hammer->new(
	hostname => 'funnycow.com',
	thread_count => 10
);

$hammer->start;


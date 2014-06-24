#!/usr/bin/perl -w
use strict;
use WWW::Mechanize::Timed;

my $mech = WWW::Mechanize::Timed->new;

$mech->get('http://rotogrinders.com/');

print $mech->title . "\n";

print $mech->client_response_server_time . "\n";
print $mech->client_total_time . "\n";
print $mech->client_elapsed_time . "\n";

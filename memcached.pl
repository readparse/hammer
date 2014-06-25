#!/usr/bin/perl -w
use Hammer::Memcached;
use Data::Dumper;

my $cache = Hammer::Memcached->new;

my $cached = $cache->get_hash;

$cached->{company} = 'rotogrinders';

$cache->set_hash($cached);

print Dumper($cached);

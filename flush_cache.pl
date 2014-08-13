#!/usr/bin/perl -w
use strict;
use Hammer::Memcached;


my $cache = Hammer::Memcached->new;
$cache->delete_hash;

package Hammer::Action;
use Moose;
use WWW::Mechanize::Timed;
use Hammer::Memcached;
use Data::Dumper;

has name => (is => 'rw');
has hostname => (is => 'rw');
has protocol => (is => 'rw');
has agent => (is => 'rw', isa => 'WWW::Mechanize::Timed');
has cache => (is => 'rw', isa => 'Hammer::Memcached', lazy_build => 1);
has timestamp => (is => 'rw');

sub _build_cache { return Hammer::Memcached->new }

sub report_time {
	my ($this, $time) = @_;
	my $hash = $this->cache->get_hash;
	$hash->{$this->timestamp}->{$this->name} = [] unless $hash->{$this->timestamp}->{$this->name};
	push(@{$hash->{$this->timestamp}->{$this->name}}, $time);
	$this->cache->set_hash($hash);
}

1;

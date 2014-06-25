package Hammer::Action;
use Moose;
use Data::Dumper;
use Time::HiRes qw( gettimeofday );
use Hammer::Memcached;

has name => (is => 'rw');
has hostname => (is => 'rw');
has protocol => (is => 'rw');
has agent => (is => 'rw', isa => 'WWW::Mechanize::Timed');
has times => (is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub { [] } );
has cache => (is => 'rw', isa => 'Hammer::Memcached', lazy_build => 1);
has id => (is => 'rw', lazy_build => 1);

sub _build_cache { return Hammer::Memcached->new }

sub _build_id {
	my @chars = ('A'..'Z');
	return join('', map { $chars[rand @chars] } (1..16));
}

sub report_time {
	my ($this, $time) = @_;
	#my $hash = $this->cache->get_hash;
	#print Dumper($hash);
}

sub average {
	my $this = shift;
	print $this->cache;	
	my $total = 0;
	my $count = 0; 
	for my $time ($this->times) {
		$total += $time;
		$count++;
	}
	#return sprintf("", $count / $total);
}

1;

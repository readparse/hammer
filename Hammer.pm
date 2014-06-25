package Hammer;
use Moose;
use Data::Dumper;
use WWW::Mechanize::Timed;
use threads;
use Cache::Memcached;

has hostname => (is => 'rw');
has protocol => (is => 'rw');
has thread_count => (is => 'rw', default => sub { 10 } );
has threads => (is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub {[]});
has actions => (is => 'rw', isa => 'ArrayRef[Hammer::Action]', auto_deref => 1, default => sub {[]});
has cache => (is => 'rw', isa => 'Cache::Memcached', lazy_build => 1);
has cache_servers => (is => 'rw', isa => 'ArrayRef');

sub _build_cache { return Cache::Memcached->new({ servers => shift->cache_servers }) }

sub start {
	my $this = shift;
	for my $i (1..$this->thread_count) {
		push(@{$this->threads}, threads->create('start_thread', $this));		
		print "$@\n";
	}	
	$this->join;
}

sub join {
	my $this = shift;
	for my $thread($this->threads) {
		eval {
			my $return = $thread->join;
		};
		print "$@\n";
	}
}

sub start_thread {
	my $this = shift;
	my $mech = WWW::Mechanize::Timed->new;
	for my $action($this->actions) {
		print "Action " . $action->name . " is $action\n";
		$action->hostname($this->hostname);
		$action->protocol($this->protocol);
		$action->agent($mech);
		$action->cache($this->cache);
		my $elapsed = $action->run;
		#$action->report_time($elapsed);
	}
}

1;


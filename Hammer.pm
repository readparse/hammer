package Hammer;
use Moose;
use Data::Dumper;
use WWW::Mechanize::Timed;
use Hammer::Memcached;
use threads;

has hostname => (is => 'rw');
has protocol => (is => 'rw');
has thread_count => (is => 'rw', default => sub { 10 } );
has sleep => (is => 'rw', default => sub { 0 } );
has repeat => (is => 'rw', default => sub { 1 } );
has threads => (is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub {[]});
has actions => (is => 'rw', isa => 'ArrayRef[Hammer::Action]', auto_deref => 1, default => sub {[]});
has timestamp => (is => 'rw', lazy_build => 1);
has flush => (is => 'rw', isa => 'Bool', default => sub { 0 } );
has cache => (is => 'rw', isa => 'Hammer::Memcached', lazy_build => 1);
has results => (is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub {[]} );
has verbose => (is => 'rw', isa => 'Bool', default => sub { 0 });
has draftcity => (is => 'rw', isa => 'Bool', default => sub { 0 });
has series => (is => 'rw', isa => 'Num');

sub _build_cache { return Hammer::Memcached->new }

sub _build_timestamp { time };

sub start {
	my $this = shift;
	if ($this->flush) {
		$this->cache->delete_hash;
	}
	for my $r (1..$this->repeat) {
		warn "Round $r of " . $this->repeat . "\n";
		for my $i (1..$this->thread_count) {
			push(@{$this->threads}, threads->create('start_thread', $this, "$r$i"));		
		}	
		$this->join;
		$this->threads([]);
	}
}

sub join {
	my $this = shift;
	for my $thread($this->threads) {
		my $return = $thread->join;
		my $results = $this->results;
		push(@{$results}, $return);
		$this->results($results);
	}
}

sub start_thread {
	my ($this, $increment) = @_;
	my $username = 'hammer_' . ($this->series + $increment);
	my $email = "$username\@rotogrinders.com";
	$this->run_actions( { username => $username, email => $email } );
}

sub run_actions {
	my $this = shift;
	my $params = shift;
	my $mech = WWW::Mechanize::Timed->new;
	$mech->timeout(10);
	$mech->credentials( 'draft', 'city') if $this->draftcity;
	my @times;
	for my $action($this->actions) {
		print "Running action \"" . $action->name . "\"\n" if $this->verbose;
		$action->agent($mech);
		$this->pass_along($action);
		my $elapsed = $action->run($params);
		push(@times, { action => $action->name, time => $elapsed, uri => $action->uri });
		$action->report_time($elapsed);
		if ($this->sleep) {
			#print "Sleeping for " . $this->sleep . " second(s)\n";
			sleep $this->sleep;
		}
	}
	return \@times;
}

sub pass_along {
	my ($this, $action) = @_;
	$action->hostname($this->hostname);
	$action->protocol($this->protocol);
	$action->timestamp($this->timestamp);
}

sub wiki_report {
	my $this = shift;
	my $actions = $this->make_actions_hash;
	for my $action(sort keys(%{$actions})) {
		my $times = $actions->{$action};
		my $stats = Hammer::Stats->new( set => $times, thread_count => $this->thread_count, precision => 6, repeat => $this->repeat );
		print "h3. $action:\n";
		print "* *Mean:* " . $stats->mean . "\n";
		print "* *Max:* " . $stats->max . "\n";
		print "* *Min:* " . $stats->min . "\n";
		print "* *Requests per second:* " . $stats->requests_per_second . "\n";
		print "\n";
	}

}

sub make_actions_hash {
	my $this = shift;
	my $actions = {};
	my $data = scalar $this->results;
	for my $stack(@{$data}) {
		for my $result(@{$stack}) {
			my $action = $result->{action};
			my $time = $result->{time};
			push(@{$actions->{$action}}, $time);
		} 
	}
	return $actions;
}

sub report {
	my $this = shift;
	my $actions = $this->make_actions_hash;
	for my $action(keys(%{$actions})) {
		my $times = $actions->{$action};
		my $stats = Hammer::Stats->new( set => $times );
		print "$action:\n";
		print "  Mean: " . $stats->mean . "\n";
		print "  Max: " . $stats->max . "\n";
		print "  Min: " . $stats->min . "\n";
	}
}

1;


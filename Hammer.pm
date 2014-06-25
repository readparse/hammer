package Hammer;
use Moose;
use Data::Dumper;
use WWW::Mechanize::Timed;
use threads;

has hostname => (is => 'rw');
has protocol => (is => 'rw');
has thread_count => (is => 'rw', default => sub { 10 } );
has threads => (is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub {[]});
has actions => (is => 'rw', isa => 'ArrayRef[Hammer::Action]', auto_deref => 1, default => sub {[]});
has timestamp => (is => 'rw', lazy_build => 1);
has flush => (is => 'rw', isa => 'Bool', default => sub { 0 } );

sub _build_timestamp { time };

sub start {
	my $this = shift;
	for my $i (1..$this->thread_count) {
		push(@{$this->threads}, threads->create('start_thread', $this));		
	}	
	$this->join;
}

sub join {
	my $this = shift;
	for my $thread($this->threads) {
		my $return = $thread->join;
	}
}

sub start_thread {
	my $this = shift;
	$this->run_actions;
}

sub run_actions {
	my $this = shift;
	my $mech = WWW::Mechanize::Timed->new;
	for my $action($this->actions) {
		$action->agent($mech);
		$this->pass_along($action);
		my $elapsed = $action->run;
		$action->report_time($elapsed);
	}
}

sub pass_along {
	my ($this, $action) = @_;
	$action->hostname($this->hostname);
	$action->protocol($this->protocol);
	$action->timestamp($this->timestamp);
}
1;


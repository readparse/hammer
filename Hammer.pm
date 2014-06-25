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
		$action->hostname($this->hostname);
		$action->protocol($this->protocol);
		$action->agent($mech);
		my $elapsed = $action->run;
		print "$elapsed\n";
	}
}

1;


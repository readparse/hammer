package Hammer;
use Moose;
use threads;
use Data::Dumper;

has hostname => (is => 'rw');
has thread_count => (is => 'rw', default => sub { 10 } );
has threads => (is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub {[]});

sub start {
	my $this = shift;
	for my $i (1..$this->thread_count) {
		push(@{$this->threads}, threads->create('do_stuff') );		
	}	
	$this->join;
}

sub join {
	my $this = shift;
	for my $thread($this->threads) {
		$thread->join;
	}
}

sub do_stuff {
	print "hey\n";
}
1;


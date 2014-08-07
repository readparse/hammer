package Hammer::Action::GetURI;
use Moose;
extends 'Hammer::Action';

has uri => ( is => 'rw' );

sub run {
	my $this = shift;
	my $mech = $this->agent;
	$mech->get($this->fully_qualified);
	my $title = $mech->title || 'Untitled';
	#return $mech->client_elapsed_time;
	#return $mech->client_total_time;
	return $mech->client_total_time;
}

sub fully_qualified {
	my $this = shift;
	return sprintf("%s://%s%s", $this->protocol, $this->hostname, $this->uri);
}

1;

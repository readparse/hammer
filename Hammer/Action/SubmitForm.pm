package Hammer::Action::SubmitForm;
use Moose;
extends 'Hammer::Action';

has form_number => ( is => 'rw' );
has fields => ( is => 'rw', isa => 'HashRef' );

sub run {
	my $this = shift;
	my $mech = $this->agent;
	$mech->get($this->fully_qualified);
	my $title = $mech->title || 'Untitled';
	if (my $num = $this->form_number) {
		if (my $fields = $this->fields) {
			if ($mech->submit_form( form_number => $num, fields => $fields)) {
				return $mech->client_total_time;
			}
		}
	}
}


1;

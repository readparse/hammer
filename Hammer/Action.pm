package Hammer::Action;
use Moose;

has name => (is => 'rw');
has hostname => (is => 'rw');
has protocol => (is => 'rw');
has agent => (is => 'rw', isa => 'WWW::Mechanize');

1;

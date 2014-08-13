#!/usr/bin/perl -w
use strict;
use Hammer; 
use Hammer::Action::GetURI;
use Hammer::Action::SubmitForm;
use Hammer::Stats;
use Getopt::Long;
use Data::Dumper;
use Storable;

my ($hostname, $thread_count, $repeat, $flush, $maxdepth, $uri) = (undef, undef, 1, 0, 999, undef);

GetOptions(
	"hostname=s" => \$hostname,
	"thread_count=i" => \$thread_count,
	"repeat=i" => \$repeat,
	"flush" => \$flush,
	"maxdepth=i" => \$maxdepth,
	"uri" => \$uri,
);

if ($hostname && $thread_count) {
	my $hammer = Hammer->new(
		protocol => 'http',
		hostname => $hostname,
		thread_count => $thread_count,
		flush => $flush,
		repeat => $repeat,
		actions => [
			Hammer::Action::GetURI->new( name => 'Home Page', uri => '/'),
			Hammer::Action::GetURI->new( name => 'Lineups', uri => '/lineups'),
			Hammer::Action::GetURI->new( name => 'GrindersLive', uri => '/live'),
			Hammer::Action::GetURI->new( name => 'MLB Daily Batter Hub', uri => '/pages/Hot_Streak_Hitters-56970'),
			Hammer::Action::SubmitForm->new( 
				name => 'Submit Login Form', 
				uri => '/sign-in', 
				form_number => 3,
				fields => {
					username => 'readparse',
					password => 'phantom',
				}
			),
			Hammer::Action::SubmitForm->new( 
				name => 'Post to Main Forum', 
				uri => '/threads/category/main/create', 
				form_number => 1,
				fields => {
					title => 'Hammer was here, big time',
					text => lipsum()
				}
			),
		]
	);

	if ($uri) {
		$hammer->actions( Hammer::Action::GetURI->new(  name => 'Custom URI', uri => $uri  ) );
	}	
	$hammer->start;
	$hammer->wiki_report;
} else {
	usage();
}

sub usage {
	print "You must specific both a hostname and a thread_count\n";
}


sub lipsum {
return <<OUT;
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean dictum ut dolor a sollicitudin. Nullam imperdiet, urna nec condimentum lacinia, tortor elit faucibus magna, non consectetur purus massa in nulla. Morbi lacinia auctor justo sit amet vestibulum. Donec nec ante dolor. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Quisque interdum, velit ac molestie feugiat, mauris sem fringilla magna, in suscipit metus lacus a risus. Ut rhoncus aliquet sapien, nec facilisis elit. Donec mollis et tellus id euismod. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non tellus odio. Duis sed nisl commodo, tincidunt massa in, tincidunt sapien. Phasellus semper erat vitae vehicula ornare. Etiam et nisl mollis, molestie tortor ut, consectetur lectus. Morbi sed turpis ornare, cursus turpis et, luctus urna.

Fusce vitae turpis sed magna sollicitudin consectetur. Integer quis magna elementum, malesuada arcu a, gravida ipsum. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nullam faucibus mi in ultricies bibendum. Morbi aliquet, diam quis aliquet porta, diam ante mattis odio, quis semper nulla augue at eros. Cras iaculis ipsum eget neque rutrum, ac ornare lacus porttitor. Donec congue a nisi sed feugiat. Aliquam euismod imperdiet scelerisque. Duis arcu odio, convallis id molestie at, placerat in erat. Duis ornare sodales aliquet. Sed a dapibus sem. Nunc sit amet consectetur ipsum. Vestibulum lorem velit, aliquam vel nulla in, aliquam convallis massa. Pellentesque ac sapien elit. Mauris tristique mollis sapien porta convallis.
OUT
}

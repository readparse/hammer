package Hammer::Stats;
use Moose;
use Data::Dumper;

has set => ( is => 'rw', isa => 'ArrayRef[Num]', auto_deref => 1, trigger => \&make_ordered_set );
has precision => ( is => 'rw', isa => 'Num', default => sub { 2 } );
has ordered_set => ( is => 'rw', isa => 'ArrayRef[Num]', auto_deref => 1 );
has set_string => ( is => 'rw', isa => 'Str', trigger => \&make_set ); 
has thread_count => ( is => 'rw', isa => 'Num' ); 
has repeat => ( is => 'rw', isa => 'Num' ); 

sub make_set {
	my $this = shift;
	my @numbers = split(/[^\d\.]+/, $this->set_string);
	$this->set(\@numbers);
}

sub make_ordered_set {
	my $this = shift;
	if (my $set = $this->set) {
		my @ordered = sort { $a <=> $b} @{$set};
		$this->ordered_set(\@ordered);
	}
}

sub median {
	my $this = shift;
	my $set = shift || $this->ordered_set;
	my $count = scalar @{$set};
	my $half;
	if ($this->set_is_odd) {
		$half = ($count - 1) / 2;
		return $set->[$half];
	} else {
		$half = $count / 2;
		my $first = $set->[$half - 1];
		my $second = $set->[$half];
		return $this->average([$first, $second]);
	}
}

sub average {
	my $this = shift;
	my $list = shift;
	my $total = 0;
	my $count = 0;
	map { $total += $_; $count++ } @{$list};
	my $format = '%.' . $this->precision . 'f';
	my $avg = sprintf($format, $total / $count);
	$avg =~ s/0+$//;
	$avg =~ s/\.$//;
	return $avg;
}

sub mean {
	my $this = shift;
	return $this->average(scalar $this->set);
}

sub summary {
	my $this = shift;
	my @out = (
		$this->min,
		$this->q1,
		$this->median,
		$this->q3,
		$this->max
	);
	return wantarray ? @out : \@out;
}

sub info {
	my $this = shift;
	print "Range: " . $this->range . "\n";
	print "Mean: " . $this->mean . "\n";
	print "Median: " . $this->median . "\n";
	print "Min: " . $this->min . "\n";
	print "Max: " . $this->max . "\n";
	print "Q1: " . $this->q1 . "\n";
	print "Q3: " . $this->q3 . "\n";
	print "IQR: " . $this->iqr . "\n";
	print "1.5(IQR): " . $this->iqr15 . "\n";
	print "Std Dev: " . $this->deviation . "\n";
	if (my @outliers = $this->outliers) {
		my $string = join(', ', @outliers);
		print "Outliers: $string\n";
	}
	print "\n";
}

sub stemplot {
	my $this = shift;
	my $index = {};
	for my $item ($this->ordered_set) {
		my ($first, $second) = ($1,$2) if $item =~ /^([\d\.]+)(\d)$/;
		$index->{$first} = [] unless $index->{$first};
		push(@{$index->{$first}}, $second);
	}
	for my $key( sort {$a <=> $b} (keys(%{$index}))) {
		my $string = join(' ', @{$index->{$key}});
		print "$key|$string\n";
	}
}

sub count {
	my $this = shift;
	return scalar @{$this->set};
}

sub set_is_odd { 
	my $this = shift;
	return $this->count % 2;
}

sub set_is_even {
	return shift->set_is_odd ? 0 : 1;
}

sub iqr {
	my $this = shift;
	return $this->q3 - $this->q1;
}

sub iqr15 {
	shift->iqr * 1.5;
}

sub deviation {
	my $this = shift;
	my $mean = $this->mean;
	my $total = 0;
	my $set = $this->ordered_set;
	my $count = $this->count;
	for my $item(@{$set}) {
		my $dev = ($item - $mean)**2;
		$total += $dev;
	}
	my $variance = $total / ($count-1);
	return $this->format(sqrt($variance));
}

sub format {
	my $this = shift;
	my $value = shift;
	my $format = '%.' . $this->precision . 'f';
	my $out = sprintf($format, $value);
	#$out =~ s/0+$//;
	#$out =~ s/\.$//;
	return $out;
}

sub range {
	my $this = shift;
	return $this->max - $this->min;
}

sub max { 
	my $this = shift;
	my $format = '%.' . $this->precision . 'f';
	return sprintf($format, $this->ordered_set->[$this->count - 1]); 
}

sub min { 
	my $this = shift;
	my $format = '%.' . $this->precision . 'f';
	return sprintf($format, $this->ordered_set->[0]); 
}

sub half {
	my $this = shift;
	my $key = shift;
	my @set = $this->ordered_set;
	my $count = $this->count;
	my @out;
	my $index = $this->set_is_odd ? ($count / 2 - 1) : $count / 2;
	if ($key eq 'lower') {
			@out = splice(@set, 0, $index);
	} else {
		@out = splice(@set, $index);
	}
	return wantarray ? @out : \@out;
}

sub lower_half { shift->half('lower') }
sub upper_half { shift->half('upper') }

sub q1 {
	my $this = shift;
	return $this->median(scalar $this->lower_half);
}

sub q3 {
	my $this = shift;
	return $this->median(scalar $this->upper_half);
}

sub upper_outliers {
	my $this = shift;
	my @out = map { $_ > $this->q3 + $this->iqr15 ? $_ : () } $this->upper_half;
	if (scalar @out) {
		return wantarray ? @out : \@out;
	} else {
		return;
	}
}

sub lower_outliers {
	my $this = shift;
	my @out = map { $_ < $this->q1 - $this->iqr15 ? $_ : () } $this->lower_half;
	if (scalar @out) {
		return wantarray ? @out : \@out;
	} else {
		return;
	}
}

sub outliers {
	my $this = shift;
	my @out = ($this->lower_outliers, $this->upper_outliers);
	if (scalar @out) {
		return wantarray ? @out : \@out;
	} else {
		return;
	}

}

sub requests_per_second {
	my $this = shift;
	my $total_time = 0;
	for my $item($this->set) {
		$total_time += $item;
	}
	return sprintf("%.6f", $this->repeat * $this->thread_count / $total_time);
}

1;


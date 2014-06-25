package Hammer::Memcached;
use Moose;
use Cache::Memcached;

has servers => (is => 'rw', isa => 'ArrayRef', default => sub { [ '127.0.0.1:11211' ] }  );
has cache => (is => 'rw', isa => 'Cache::Memcached', lazy_build => 1);
has key => (is => 'rw', default => sub { 'THIS_KEY_HAS_NO_NAME' }  );

sub _build_cache { return Cache::Memcached->new( { servers => shift->servers } ) }

sub get_hash { 
	my $this = shift;
	$this->cache->get($this->key) || {}  
}

sub set_hash { 
	my ($this, $value) = @_;
	$this->cache->set($this->key, $value);
}

1;

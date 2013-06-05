use strict;
use warnings FATAL => 'all';
use Test::More;
use Acme::Parse::Meaning;
use Data::Dumper::Concise;
my $one_pn = "I'm going to New York.";
my $parser = Acme::Parse::Meaning->new( text => $one_pn );
ok $parser->parse;
1;

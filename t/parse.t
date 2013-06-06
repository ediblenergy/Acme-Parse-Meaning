use strict;
use warnings FATAL => 'all';
use Test::More;
plan tests => 1;
use Acme::Parse::Meaning;
use Data::Dumper::Concise;
my $one_pn = "Im going to New York";
#my $one_pn = "5 + 6";
my $parser = Acme::Parse::Meaning->new( text => $one_pn );
#diag Dumper $parser->parse;
ok $parser->parse,
  'successfully parsed';
1;

use strict;
use warnings FATAL => 'all';
use Test::More;
plan tests => 1;
use Acme::Parse::Meaning;
use Data::Dumper::Concise;
my $one_pn = "I'm going to New York. Then I will fly to Georgia.";
#my $one_pn = "5 + 6";
my $parser = Acme::Parse::Meaning->new( text => $one_pn );
#diag Dumper $parser->parse;
ok $parser->parse,
  'successfully parsed';
1;

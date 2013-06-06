package Acme::Parse::Meaning;
use strict;
use warnings FATAL => 'all';
use Moo;
use Marpa::R2;
use feature 'say';
use Data::Dumper::Concise;

has text => (
    is => 'ro',
    required => 1,
);

has grammar => ( is => 'lazy' );

has proper_nouns => ( is => 'lazy' );

sub _build_grammar {
    my $source =<<'EOS';
:start              ::= document
document            ::= paragraph+
paragraph           ::= sentence+
sentence            ::= sentence_part+
sentence_part       ::=  words  action => add_word
words               ::= word_and_space+
word_and_space      ::= opt_whitespace word opt_whitespace 
word                ~ letters
letters             ~ letter+
letter              ~ [\w]
opt_whitespace      ::= [\h]*
EOS

    return Marpa::R2::Scanless::G->new(
        {
            source         => \$source,
            action_object  => 'MeaningNodes',
            default_action => '::first',
        } );
    return $source;
}

=head2 BUsted
proper_noun         ~ [\b\w+\b]
sentence_part       ::= word+ | proper_noun
capitalized-word  ::= WORD_BORDER UPPER_CASE_LETTER LOWER_CASE_LETTER+ WORD_BORDER | PUNCTUATION_MARK
:start ::= Expression
Expression ::= Term
Term ::=
      Factor
    | Term '+' Term action => do_add
Factor ::=
      Number
    | Factor '*' Factor action => do_multiply
      Number ~ digits
      digits ~ [\d]+
      :discard ~ whitespace
      whitespace ~ [\s]+


document          ::= paragraph+
paragraph         ::= sentence+ VERTICAL_SPACE
VERTICAL_SPACE ~  [\v]+
sentence part     ::= word+ | proper-noun | opt-punctuation
<word>              ::= LETTER+
<opt-punctuation>   ::= PUNCTUATION_MARK | ""
<proper-noun>       ::= capitalized-word+
<capitalized-word>  ::= WORD_BORDER UPPER_CASE_LETTER LOWER_CASE_LETTER+ WORD_BORDER | PUNCTUATION_MARK

=cut

sub parse {
    my $self = shift;
    warn 'before recce';
    my $recce = Marpa::R2::Scanless::R->new( { grammar => $self->grammar, trace_terminals => 1 } );
    warn 'after recce';
    my $content = $self->text;
    warn "trying to parse '$content'";
#    warn $self->grammar->show_symbols;
#    warn $self->grammar->show_rules;
    $recce->read( \$content );
    my $value_ref = $recce->value;
    my $value = $value_ref ? ${$value_ref} : 'No Parse';
}

sub MeaningNodes::new { +{} }
sub MeaningNodes::add_word {
    my($self,$word) = @_;
    say Dumper \@_;
    return $word;
}

1;

__END__
=head1 NAME

  Acme::Parse::Meaning

=head1 BNF

    <document>          ::= paragraph+
    <paragraph>         ::= sentence+ VERTICAL_SPACE
    <sentence>          ::= sentence-part+ .
    <sentence-part>     ::= word+ | proper-noun | opt-punctuation
    <word>              ::= LETTER+
    <opt-punctuation>   ::= PUNCTUATION_MARK | ""
    <proper-noun>       ::= capitalized-word+
    <capitalized-word>  ::= " " UPPER_CASE_LETTER LOWER_CASE_LETTER+ " " | PUNCTUATION_MARK

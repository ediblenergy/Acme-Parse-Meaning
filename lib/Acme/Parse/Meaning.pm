package Acme::Parse::Meaning;
use strict;
use warnings FATAL => 'all';
use Moo;
use Marpa::R2;
use feature 'say';

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
sentence_part       ::=   words | proper_noun
words ::= words_and_space+
words_and_space ::= word opt_whitespace 
opt_whitespace ~ [\h]+
word                 ~ [\b\w+\b]
proper_noun       ~ [\b\w+\w]
EOS

=head2 BUsted
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

      return Marpa::R2::Scanless::G->new({
        source         => \$source,
        action_object  => 'MeaningNodes',
        default_action => '::first',
    });
    return $source;
}
sub parse {
    my $self = shift;
    warn 'before recce';
    my $recce = Marpa::R2::Scanless::R->new( { grammar => $self->grammar } );
    warn 'after recce';
    my $content = $self->text;
    warn "trying to parse '$content'";
    $recce->read( \$content );
    my $value_ref = $recce->value;
    my $value = $value_ref ? ${$value_ref} : 'No Parse';
}

sub MeaningNodes::new { +{} }
sub MeaningNodes::do_add {
    return @_;
}

sub MeaningNodes::do_multiply {
    return @_;
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

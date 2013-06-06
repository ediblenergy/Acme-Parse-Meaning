package Acme::Parse::Meaning;
use strict;
use warnings FATAL => 'all';
use Moo;
use Marpa::R2;
use feature 'say';
use Data::Dumper::Concise;
use Log::Contextual qw[ :log :dlog set_logger ];
use Log::Contextual::SimpleLogger;
set_logger(Log::Contextual::SimpleLogger->new(
    { levels => [qw/warn debug/] } ));


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
sentence            ::= sentence_parts '.'  action => dump_sentence
sentence_parts      ::= sentence_part+
sentence_part       ::= words
words               ::= word_and_space+ 
word_and_space      ::= opt_whitespace word opt_whitespace action => add_word
word                ::= letters action => ::first
letters             ~   letter+
letter              ~   [\w] | [']
opt_whitespace      ::= [\h]*
EOS
#word                ::= letters action => add_word

    return Marpa::R2::Scanless::G->new(
        {
            source         => \$source,
            action_object  => 'MeaningNodes',
            default_action => '::array',
        } );
    return $source;
}

=head2 BUsted
words               ::= word_and_space+ action => collect_word_and_space
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
    log_debug { 'before recce' };
    my $recce = Marpa::R2::Scanless::R->new( { grammar => $self->grammar, trace_terminals => 1 } );
    warn 'after recce';
    my $content = $self->text;
    warn "trying to parse '$content'";
#    warn $self->grammar->show_symbols;
#    warn $self->grammar->show_rules;
    $recce->read( \$content );
    my $value_ref = $recce->value;
    Dlog_debug { "value:$_" } $value_ref;
    my $value = $value_ref ? ${$value_ref} : 'No Parse';
}

sub MeaningNodes::new {
    +{ words => [] }
}
sub MeaningNodes::add_word {
    my($self,undef,$word,undef) = @_;
    Dlog_debug { "MeaningNodes::add_word $_" } \@_;
#    push( @{$self->{words}}, $word );
    return \$word;#$self->{words};
}

sub MeaningNodes::dump_sentence {
    Dlog_debug { "MeaningNodes::dump_sentence: $_" } \@_;
    return \@_;
}

sub MeaningNodes::dump_sentence_part {
    Dlog_debug { "MeaningNodes::dump_sentence_part $_" } \@_;
}

sub MeaningNodes::collect_word_and_space {
    Dlog_debug { "MeaningNodes::collect_word_and_space $_" } \@_;
}

sub MeaningNodes::identity {
    shift;
    Dlog_debug { "MeaningNodes::identity: $_" } @_;
    return unless @_;
    return \@_;
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

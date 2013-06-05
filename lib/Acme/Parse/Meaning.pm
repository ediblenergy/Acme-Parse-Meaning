package Acme::Parse::Meaning;
use strict;
use warnings FATAL => 'all';
use Moo;
use Marpa::R2;

has text => (
    is => 'ro',
    required => 1,
);

has grammar => ( is => 'lazy' );

has proper_nouns => ( is => 'lazy' );

sub _build_grammar {
    my $source =<<"EOS";
    <document>          ::= paragraph+
    <paragraph>         ::= sentence+ VERTICAL_SPACE
    <sentence>          ::= sentence-part+ .
    <sentence-part>     ::= word+ | proper-noun | opt-punctuation
    <word>              ::= LETTER+
    <opt-punctuation>   ::= PUNCTUATION_MARK | ""
    <proper-noun>       ::= capitalized-word+
    <capitalized-word>  ::= " " UPPER_CASE_LETTER LOWER_CASE_LETTER+ " " | PUNCTUATION_MARK
EOS

      return Marpa::R2::Scanless::G->new({
        source         => \$source,
        action_object  => 'MeaningNodes',
        default_action => '::first',
    });
    return $source;
}
sub parse {
    my $self = shift;
    my $recce = Marpa::R2::Scanless::R->new( { grammar => $self->grammar } );
    my $content = $self->text;
    $recce->read( \$content );
    my $value_ref = $recce->value;
    my $value = $value_ref ? ${$value_ref} : 'No Parse';
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

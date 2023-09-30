package Lucia::Dictionary;

use strict;
use warnings;

use Lucia::Utils::File qw(get_resources_dir load_json);

use constant LEXICON_DIR      => sprintf '%s/translates', get_resources_dir();
use constant LEXICON_FILENAME => 'lexicon.json';
use constant LEXICON_FILEPATH => sprintf '%s/%s', LEXICON_DIR, LEXICON_FILENAME;

sub new {
    my $class = shift;

    my $self = {
        _lang    => undef,
        _lexicon => load_json(LEXICON_FILEPATH)
    };

    return bless $self, $class;
}

sub set_lang {
    my ($self, $lang) = @_;    
    $self->{_lang} = $lang;
    return;
}

sub get_definition {
    my ($self, $term) = @_;

    my $lexicon = $self->{_lexicon};
    my $lang = $self->{_lang};
    my $definition = $lexicon->{$term}->{$lang};

    return $definition;
}

sub get_formatted_definition {
    my ($self, $term, $items) = @_;

    my $definition = $self->get_definition($term);

    if ($items) {
        my @items = @{$items};
        $definition = sprintf $definition, @items;
    }

    return $definition;
}

1;

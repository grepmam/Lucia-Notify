package Lucia::Dictionary;

use strict;
use warnings;


sub new {

    my $class = shift;
    my $self = {
        _lexicon => Lucia::Utils::File::load_json(
            'resources/translates/lexicon.json'
        )
    };

    return bless $self, $class;

}

sub get_definition {

    my ( $self, $term, $lang ) = @_;

    my $lexicon = $self->{_lexicon};
    my $definition = $lexicon->{$term}->{$lang};

    return $definition;

}


1;

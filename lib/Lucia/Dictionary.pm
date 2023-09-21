package Lucia::Dictionary;

use strict;
use warnings;

use Lucia::Utils::File;


sub new {

    my ( $class, $dict_file ) = @_;

    my $self = {
        _lexicon => Lucia::Utils::File::load_json($dict_file)
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

package Translate;

use strict;
use warnings;

use lib '.';
use Utils;


my $lexicon = Utils::load_json('translates/lexicon.json');

sub translate_term {

    my ( $term, $lang ) = @_;

    my $translation = $lexicon->{$term}->{$lang};

    return $translation;

}


1;

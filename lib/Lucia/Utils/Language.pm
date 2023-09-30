package Lucia::Utils::Language;

use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(lang_exists);
our @AVAILABLE_LANGUAGES = ( 'en', 'es' );


sub lang_exists {
    my $lang = shift;
    return grep { $_ eq $lang } @AVAILABLE_LANGUAGES;
}

1;

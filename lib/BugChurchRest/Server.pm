package BugChurchRest::Server;

use strict;
use warnings;

use Dancer2;
use BugChurchRest::Controllers::Bug;

sub run {
    start;
    return;
}

1;

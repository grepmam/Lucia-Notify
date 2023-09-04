package BugChurchRest::Controllers::User;

use strict;
use warnings;

use Dancer2 appname => 'BugChurchRest';

use BugChurchRest::Models::Bug;

set serializer => 'JSON';

get '/api/bugs/:id[Int]' => sub {

    my $id = param('id');

    my $bm  = BugChurchRest::Models::Bug->new;
    my $bug = $bm->get_bug_by_id($id);

    my $bh = {};

    if ($bug) {
        $bh = {
            id           => $bug->get_id,
            status       => $bug->get_status,
            description  => $bug->get_description,
            rep_platform => $bug->get_rep_platform,
            resolution   => $bug->get_resolution
        };
    }

    return $bh;

};

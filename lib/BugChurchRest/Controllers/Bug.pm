package BugChurchRest::Controllers::Bug;

use strict;
use warnings;

use Dancer2 appname => 'BugChurchRest';

use BugChurchRest::Models::Bug;

set serializer => 'JSON';

get '/api/bugs' => sub {

    my $id = param('id');

    my $bm = BugChurchRest::Models::Bug->new;
    my $bugs = $bm->get_bugs_by_ids( $id );

    if ( ! @$bugs ) {
        status 404;
        return { message => 'Bugs not found' }
    }

    my @bugs;
    
    foreach my $bug ( @$bugs ) {
        my $bug = {
            id           => $bug->get_id,
            status       => $bug->get_status,
            description  => $bug->get_description,
            rep_platform => $bug->get_rep_platform,
            resolution   => $bug->get_resolution
        };
        push @bugs, $bug;
    }

    return { bugs => \@bugs };

};

get '/api/bugs/user/:id[Int]' => sub {

    my $user_id = param('id');

    my $bm = BugChurchRest::Models::Bug->new;
    my $bugs = $bm->get_bugs_by_userid($user_id);

    if ( ! @$bugs ) {
        status 404;
        return { message => 'Bugs not found' }
    }

    my @bugs;
    
    foreach my $bug ( @$bugs ) {
        my $bug = {
            id           => $bug->get_id,
            status       => $bug->get_status,
            description  => $bug->get_description,
            rep_platform => $bug->get_rep_platform,
            resolution   => $bug->get_resolution
        };
        push @bugs, $bug;
    }

    return { bugs => \@bugs };

};

1;

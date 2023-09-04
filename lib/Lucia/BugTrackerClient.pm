package Lucia::BugTrackerClient;

use strict;
use warnings;

use LWP::UserAgent;
use JSON qw(decode_json);
use BugChurchRest::Entities::Bug;

sub new {

    my $class = shift;

    my $domain = shift;
    my $port = shift;
    my $base_url = "http://$domain:$port";

    my $self = {

        _base_url => $base_url

    };

    return bless $self, $class;

}

sub get_bugs_by_ids {

    my ( $self, $bug_ids ) = @_;

    my $base_url = $self->{_base_url};
    my $url = "$base_url/api/bugs?id=$bug_ids";

    my $response = $self->do_request( $url );

    return [] unless $response->is_success;

    my $data = decode_json( $response->content );
    my $bugs = $self->_create_bugs( $data->{bugs} );

    return $bugs;

}

sub do_request {

    my ( $self, $url ) = @_;

    my $ua = LWP::UserAgent->new;
    my $response = $ua->get( $url );

    die "Error getting data from API\n" if $response->code >= 500;

    return $response;

}

sub _create_bugs {

    my ( $self, $bugs_raw ) = @_;
    
    my @bugs;
    my @bugs_raw = @$bugs_raw;

    foreach my $bug_raw ( @bugs_raw ) {
        my $bug = BugChurchRest::Entities::Bug->new;
        $bug->set_id( $bug_raw->{id} );
        $bug->set_status( $bug_raw->{status} );
        $bug->set_resolution( $bug_raw->{resolution} );
        $bug->set_description( $bug_raw->{description} );
        $bug->set_rep_platform( $bug_raw->{rep_platform} );
        push @bugs, $bug;
    }

    return \@bugs;

}

1;

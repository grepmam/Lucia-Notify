package Lucia::BugChurch::Models::Bug;

use strict;
use warnings;

use Lucia::BugChurch::Config::Database;
use Lucia::BugChurch::Entities::Bug;
use Lucia::BugChurch::Entities::User;


sub new {

    my $class = shift;
    return bless {
        _dbh => Lucia::BugChurch::Config::Database->new
    }, $class;

}

sub get_bugs_by_ids {

    my ( $self, $ids ) = @_;

    my $conn = $self->{_dbh}->get_connection();
    my $query_template = q|
        SELECT bu.bug_id, bu.bug_status, bu.short_desc,
               bu.rep_platform, bu.resolution,
               pr.realname 
        FROM bugs as bu
        INNER JOIN profiles as pr
            ON pr.userid = bu.assigned_to
        WHERE bu.bug_id IN (?);
    |;

    my $sth = $conn->prepare($query_template);
    $sth->execute($ids);

    my @bugs;

    while (my $row = $sth->fetchrow_hashref) {

        my $bug = Lucia::BugChurch::Entities::Bug->new;
        $bug->set_id($row->{bug_id});
        $bug->set_status($row->{bug_status});
        $bug->set_description($row->{short_desc});
        $bug->set_rep_platform($row->{rep_platform});
        $bug->set_resolution($row->{resolution});

        push @bugs, $bug;

    };

    $sth->finish();
    $conn->disconnect();

    return \@bugs;

}

sub get_bugs_by_userid {

    my ( $self, $userid ) = @_;

    my $conn = $self->{_dbh}->get_connection();
    my $query_template = q|
        SELECT bu.bug_id, bu.bug_status, bu.short_desc,
               bu.resolution, bu.rep_platform, pr.login_name
        FROM bugs bu
        LEFT JOIN cc as co
            ON co.bug_id = bu.bug_id
        INNER JOIN profiles as pr
            ON pr.userid = bu.assigned_to
        WHERE ( bu.assigned_to = ? OR co.who = ? )
            AND bu.bug_status <> 'CLOSED';
    |;

    my $sth = $conn->prepare($query_template);
    $sth->execute($userid, $userid);

    my @bugs;

    while (my $row = $sth->fetchrow_hashref) {

        my $user = Lucia::BugChurch::Entities::User->new;
        $user->set_email($row->{login_name});

        my $bug = Lucia::BugChurch::Entities::Bug->new;
        $bug->set_id($row->{bug_id});
        $bug->set_status($row->{bug_status});
        $bug->set_description($row->{short_desc});
        $bug->set_rep_platform($row->{rep_platform});
        $bug->set_resolution($row->{resolution});
        $bug->set_user($user);

        push @bugs, $bug;

    };

    $sth->finish();
    $conn->disconnect();

    return \@bugs;

}

1;

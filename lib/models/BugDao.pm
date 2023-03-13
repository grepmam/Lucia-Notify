package BugDao;

use strict;
use warnings;

use Database;

use lib './lib/entities';
use Bug;
use User;



sub new {

    my $class = shift;

    return bless { _dbh => Database->new }, $class;

}


sub get_bugs_by_userid {

    my ($self, $userid) = @_;

    my $conn = $self->{_dbh}->get_connection();

    my $query_template = q|
        SELECT b.bug_id, b.bug_status, b.short_desc,
               b.rep_platform, b.resolution
        FROM bugs as b
        LEFT JOIN cc as c
        ON c.bug_id = b.bug_id
        LEFT JOIN profiles as p
        ON p.userid = c.who
        WHERE ( b.assigned_to = ? OR c.who = ? )
        AND b.bug_status <> 'CLOSED'
    |;

    my $sth = $conn->prepare($query_template);
    $sth->execute($userid, $userid);

    my @bugs;

    while (my $row = $sth->fetchrow_hashref) {

        my $user = User->new;
        $user->set_realname($row->{realname});

        my $bug = Bug->new;
        $bug->set_id($row->{bug_id});
        $bug->set_status($row->{bug_status});
        $bug->set_description($row->{short_desc});
        $bug->set_rep_platform($row->{rep_platform});
        $bug->set_resolution($row->{resolution});
        $bug->set_user($user);

        push @bugs, $bug;

    }

    return \@bugs;

}


sub get_bug_by_id {

    my ($self, $id) = @_;

    my $conn = $self->{_dbh}->get_connection();
    my $query_template = q|
        SELECT b.bug_id, b.bug_status, b.short_desc,
               b.rep_platform, b.resolution,
               p.realname
        FROM bugs as b
        INNER JOIN profiles as p
        ON p.userid = b.assigned_to
        WHERE b.bug_id = ?
    |;

    my $sth = $conn->prepare($query_template);
    $sth->execute($id);

    my $row = $sth->fetchrow_hashref;

    return unless $row;

    my $user = User->new;
    $user->set_realname($row->{realname});

    my $bug = Bug->new;
    $bug->set_id($row->{bug_id});
    $bug->set_status($row->{bug_status});
    $bug->set_description($row->{short_desc});
    $bug->set_rep_platform($row->{rep_platform});
    $bug->set_resolution($row->{resolution});
    $bug->set_user($user);

    return $bug;

}


1;

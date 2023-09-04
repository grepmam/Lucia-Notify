package BugChurchRest::Models::Bug;

use strict;
use warnings;

#use BugChurchRest::Models::Database;
use BugChurchRest::Entities::Bug;

sub new {

    my $class = shift;
    return bless { _dbh => undef }, $class;

}

sub get_bugs_by_ids {

    my ( $self, $ids ) = @_;

    #my $conn = $self->{_dbh}->get_connection();
    #my $query_template = q|
    #    SELECT b.bug_id, b.bug_status, b.short_desc,
    #           b.rep_platform, b.resolution,
    #           p.realname
    #    FROM bugs as b
    #    INNER JOIN profiles as p
    #    ON p.userid = b.assigned_to
    #    WHERE b.bug_id IN (?)
    #|;

    #my $sth = $conn->prepare($query_template);
    #$sth->execute($ids);

    #my $row = $sth->fetchrow_hashref;

    my $rows = [
        {
            bug_id => 23341,
            bug_status => 'REOPENED',
            short_desc => 'Massive security breach',
            rep_platform => 'Emily',
            resolution => '',
        },
        {
            bug_id => 13591,
            bug_status => 'RESOLVED',
            short_desc => 'Privilege Escalation CVE-2023-3221',
            rep_platform => 'Emily',
            resolution => 'FIXED',
        }        
    ];

    ###################################################

    my @bugs;

    #while (my $row = $sth->fetchrow_hashref) {
    foreach my $row ( @$rows ) {

        my $bug = BugChurchRest::Entities::Bug->new;
        $bug->set_id($row->{bug_id});
        $bug->set_status($row->{bug_status});
        $bug->set_description($row->{short_desc});
        $bug->set_rep_platform($row->{rep_platform});
        $bug->set_resolution($row->{resolution});

        push @bugs, $bug;

    }

    return \@bugs;

}

sub get_bugs_by_userid {

    my ($self, $userid) = @_;

    #my $conn = $self->{_dbh}->get_connection();
    #my $query_template = q|
    #    SELECT b.bug_id, b.bug_status, b.short_desc,
    #           b.rep_platform, b.resolution
    #    FROM bugs as b
    #    LEFT JOIN cc as c
    #    ON c.bug_id = b.bug_id
    #    LEFT JOIN profiles as p
    #    ON p.userid = c.who
    #    WHERE ( b.assigned_to = ? OR c.who = ? )
    #    AND b.bug_status <> 'CLOSED'
    #|;

    #my $sth = $conn->prepare($query_template);
    #$sth->execute($userid, $userid);

    ###################################################

    my $rows = [
        {
            bug_id => 23341,
            bug_status => 'RESOLVED',
            short_desc => 'Massive security breach',
            rep_platform => 'Emily',
            resolution => 'FIXED',
        },
        {
            bug_id => 13591,
            bug_status => 'RESOLVED',
            short_desc => 'Privilege Escalation CVE-2023-3221',
            rep_platform => 'Emily',
            resolution => 'FIXED',
        }        
    ];

    $rows = [];

    ###################################################

    my @bugs;

    #while (my $row = $sth->fetchrow_hashref) {
    foreach my $row ( @$rows ) {

        my $bug = BugChurchRest::Entities::Bug->new;
        $bug->set_id($row->{bug_id});
        $bug->set_status($row->{bug_status});
        $bug->set_description($row->{short_desc});
        $bug->set_rep_platform($row->{rep_platform});
        $bug->set_resolution($row->{resolution});

        push @bugs, $bug;

    }

    return \@bugs;

}

1;

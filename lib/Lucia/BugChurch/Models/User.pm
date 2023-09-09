package Lucia::BugChurch::Models::User;

use strict;
use warnings;

use Lucia::BugChurch::Config::Database;
use Lucia::BugChurch::Entities::User;


sub new {

    my $class = shift;
    return bless {
        _dbh => Lucia::BugChurch::Config::Database->new
    }, $class;

}

sub get_user_by_username {

    my ( $self, $username ) = @_;

    my $conn = $self->{_dbh}->get_connection();
    my $query_template = q|
        SELECT userid, login_name, realname
        FROM profiles
        WHERE login_name LIKE ? 
    |;

    my $sth = $conn->prepare($query_template);
    $sth->execute("%$username%");

    my $row = $sth->fetchrow_hashref;

    return unless $row;

    my $user = Lucia::BugChurch::Entities::User->new;
    $user->set_id($row->{userid});
    $user->set_email($row->{login_name});
    $user->set_realname($row->{realname});

    return $user;

}

1;

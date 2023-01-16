package UserDao;

use strict;
use warnings;

use lib './lib/entities';
use User;
use Database;


sub new {

    my $class = shift;

    return bless { _dbh => Database->new }, $class;

}


sub dbh {
    my $self = shift;
    return $self->{_dbh}->get_connection();
}


sub get_user_by_username {

    my ($self, $username) = @_;

    my $query_template = q|
        SELECT userid, login_name, realname
        FROM profiles
        WHERE login_name LIKE ? 
    |;

    my $sth = $self->dbh->prepare($query_template);
    $sth->execute("%$username%");

    my $row = $sth->fetchrow_hashref;

    return unless $row;

    my $user = User->new;
    $user->set_id($row->{userid});
    $user->set_email($row->{login_name});
    $user->set_realname($row->{realname});

    return $user;

}


1;

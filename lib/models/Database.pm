package Database;

use strict;
use warnings;
use DBI;

use feature 'state';


sub new {

    my $class = shift;
    state $db;


    return $db if defined $db;

    my %db_data = (

        driver => 'mysql',
        schema => '',
        host   => '',
        port   => 3306,
        user   => '',
        pass   => '',

    );

    my $dsn = join ':', ('DBI', @db_data{ qw|driver schema host port| });
    my $dbh = DBI->connect($dsn, @db_data{ qw|user pass| }) or die 'DB ERROR';

    $dbh->do(q|SET NAMES 'latin1' COLLATE 'latin1_spanish_ci'|);

    $db = bless { _conn => $dbh }, $class;

    return $db;

}


sub get_connection {

    my $self = shift;
    return $self->{_conn};

}


1;

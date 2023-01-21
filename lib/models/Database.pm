package Database;

use strict;
use warnings;
use DBI;
use Dotenv;

use feature 'state';


%ENV = %{ Dotenv->parse( '.env', \%ENV ) };

use constant RECONNECT_TIME => 20;


sub new {

    my $class = shift;
    state $db;


    return $db if defined $db;

    my %db_data = (

        driver => 'mysql',
        schema => $ENV{DATABASE_NAME},
        host   => $ENV{DATABASE_HOST},
        port   => $ENV{DATABASE_PORT},
        user   => $ENV{DATABASE_USER},
        pass   => $ENV{DATABASE_PASS},

    );

    my $dsn = join ':', ('DBI', @db_data{ qw|driver schema host port| });

    my $dbh;

    while ( not defined (
            $dbh = DBI->connect($dsn, @db_data{ qw|user pass| })
        )) { sleep RECONNECT_TIME; };

    $dbh->{mysql_auto_reconnect} = 1;
    $dbh->do(q|SET NAMES 'latin1' COLLATE 'latin1_spanish_ci'|);
    $db = bless { _conn => $dbh }, $class;

    return $db;

}


sub get_connection {

    my $self = shift;
    return $self->{_conn};

}


1;

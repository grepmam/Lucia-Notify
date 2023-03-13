package Database;

use strict;
use warnings;

use DBI;
use Dotenv;

use feature 'state';

# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------

# File config

use constant FILENAME => '.env';

# Database

use constant RECONNECT_TIME => 20;


# --------------------------------------------


if ( not -e FILENAME ) {
    print sprintf 'File %s does not exists', FILENAME;
    exit 1;
}

%ENV = %{ Dotenv->parse( '.env', \%ENV ) };


# --------------------------------------------

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

    while ( ! defined ( $dbh = DBI->connect(
                $dsn, @db_data{ qw|user pass|},
                { PrintError => 0, HandleError => \&display_db_error }) )
          ) { sleep RECONNECT_TIME; }


    $dbh->{mysql_auto_reconnect} = 1;
    $dbh->do(q|SET NAMES 'latin1' COLLATE 'latin1_spanish_ci'|);
    $db = bless { _conn => $dbh }, $class;

    return $db;

}


sub get_connection {

    my $self = shift;
    return $self->{_conn};

}


sub display_db_error { print "Error connecting to DB. Retrying in " . RECONNECT_TIME . " seconds...\n"; }


1;

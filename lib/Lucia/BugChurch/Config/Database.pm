package Lucia::BugChurch::Config::Database;

use strict;
use warnings;

use DBI;
use FindBin qw($RealBin);
use Dotenv;

use constant RECONNECT_TIME => 20;

Dotenv->load("$RealBin/../.env");


sub new {
    my $class = shift;

    my $self = {
        _db_data => {
            driver => 'mysql',
            schema => $ENV{DATABASE_NAME},
            host   => $ENV{DATABASE_HOST},
            port   => $ENV{DATABASE_PORT},
            user   => $ENV{DATABASE_USER},
            pass   => $ENV{DATABASE_PASS},
        }
    };

    bless $self,$class;
    return $self;
}

sub get_conn_string {    
    my $self = shift;

    my %db_data = %{$self->{_db_data}};
    return join ':', ('DBI', @db_data{ qw|driver schema host port| });
}

sub get_connection {
    my $self = shift;
    my $conn;
    my $dsn = $self->get_conn_string();
    my %db_data = %{$self->{_db_data}};

    while (!defined(
        $conn = DBI->connect(
            $dsn,
            @db_data{qw|user pass|}, {
                PrintError  => 0,
                HandleError => \&display_db_error
            }
        )
    )) {
        sleep RECONNECT_TIME;
    }

    $conn->{mysql_auto_reconnect} = 1;
    $conn->do(q|SET NAMES 'latin1' COLLATE 'latin1_spanish_ci'|);

    return $conn;
}

sub display_db_error {
    my $message = sprintf "Error connecting to DB. Retrying in %d seconds...\n", RECONNECT_TIME;
    print $message;
    return;
}

1;

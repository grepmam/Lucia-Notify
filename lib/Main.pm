package Main;

use strict;
use warnings;

use Notify;
use Debugger;

use lib './lib/models';
use BugDao;
use UserDao;


# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------


use constant MIN_TIME_PER_QUERY => 10;


# --------------------------------------------
#
#   GLOBALS
#
# --------------------------------------------

my $session_is_active = 1;

local $SIG{INT} = sub {
    $session_is_active = 0;
    print "\n[+] Thank you for using Lucia Notify\n";
};


my $notify = Notify->new;


my %tmp_bug_states = ();


my $time;
my $sound;
my $debug;


# --------------------------------------------
#
#   Subroutine NOTIFY_FOR_TESTING
#   
# --------------------------------------------
#
#   A test notification will be displayed
#
# --------------------------------------------
#
#   -> args: HASHREF
#       sound: notification tone
#       debug: debug mode
#
#   <- status: SCALAR
#       Exit Status. 0 (Success) or 1 (Failure).
#       Unix convention.
#
# --------------------------------------------


sub notify_for_testing {

    my $args = shift;

    $sound = $args->{sound};
    $debug = $args->{debug};


    $notify->set_sound($sound);
    $notify->set_urgency(Notify::LOW);
    $notify->notify;


    Debugger::display_message(
        message  => 'Test notification has been sent',
        type     => 'success',
        activate => $debug
    );


    return 0;

}

# --------------------------------------------
#
#   Subroutine NOTIFY_FOR_BUGS
#
# --------------------------------------------
#
#   Notifications will be displayed for all 
#   bugs entered
#
# --------------------------------------------
#
#   -> args: HASHREF
#       bugs_string: bug IDs separated by ,
#       time: query time to the DB
#       sound: notification tone
#       debug: debug mode
#       nogreeting: dont display greeting
#
#   <- status: SCALAR
#       Exit Status. 0 (Success) or 1 (Failure).
#       Unix convention.
#
# --------------------------------------------


sub notify_for_bugs {

    my $args = shift;

    $time  = $args->{time};
    $sound = $args->{sound};
    $debug = $args->{debug};

    if ( not $args->{nogreeting} ) { notify_greeting(); }


    if ( $args->{bugs_string} !~ m/^(?:\d+,?)+$/ ) {
        print 'Invalid string';
        return 1;
    }


    Debugger::display_message(
        message  => sprintf( 'The following IDs will be used: %s', $args->{bugs_string} ),
        type     => 'info',
        activate => $debug
    );


    if ( $time < MIN_TIME_PER_QUERY ) {

        Debugger::display_message(
            message  => 'A very short time has been set for queries to the DB',
            type     => 'warning',
            activate => $debug
        );

        $time = 30;

    }


    # In the event that bugs that were set are eliminated
    # or do not exist, they will be deleted from the array.
    # The loop will end once the array is empty.

    my @bugs;
    my $bd = BugDao->new;

    while ( ( @bugs = grep { defined }
                    map  { $bd->get_bug_by_id($_) }
                    split /,/, $args->{bugs_string} ) &&
            $session_is_active ) {

        foreach my $bug (@bugs) { notify_bug_status($bug); }


        Debugger::display_message(
            message  => sprintf( 'Sleeping for %d seconds before continuing to check for bugs', $time ),
            type     => 'info',
            activate => $debug
        );


        sleep $time;

    }

    if ( not @bugs ) {
        print "There are no bugs for this user\n";
        return 1;
    }

    return 0;

}


# --------------------------------------------
#
#   Subroutine NOTIFY_FOR_USER_BUGS
#   
# --------------------------------------------
#
#   Notifications will be displayed for all 
#   bugs of a user
#
# --------------------------------------------
#
#   -> args: HASHREF
#       username: bugzilla username
#       time: query time to the DB
#       sound: notification tone
#       debug: debug mode
#       nogreeting: dont display greeting
#
#   <- status: SCALAR
#       Exit Status. 0 (Success) or 1 (Failure).
#       Unix convention.
#
# --------------------------------------------


sub notify_for_user_bugs {

    my $args = shift;

    $time  = $args->{time};
    $sound = $args->{sound};
    $debug = $args->{debug};


    if ( not $args->{nogreeting} ) { notify_greeting(); }


    my $ud = UserDao->new;
    my $user = $ud->get_user_by_username( $args->{username} );

    if ( not $user ) {
        print "User does not exist\n";
        return 1;
    }


    Debugger::display_message(
        message  => sprintf( 'Getting bugs from user %s', $args->{username} ),
        type     => 'info',
        activate => $debug
    );


    if ( $time < MIN_TIME_PER_QUERY ) {

        Debugger::display_message(
            message  => 'A very short time has been set for queries to the DB',
            type     => 'warning',
            activate => $debug
        );

        $time = 30;

    }

    my $bugs;
    my $bd = BugDao->new;

    while ( $session_is_active ) {

        $bugs = $bd->get_bugs_by_userid( $user->get_id );
        next if not @{$bugs};
        foreach my $bug (@{$bugs}) {  notify_bug_status( $bug ); }


        Debugger::display_message(
            message  => sprintf( 'Sleeping for %d seconds before continuing to check for bugs by user %s', $time, $args->{username} ),
            type     => 'info',
            activate => $debug
        );


        sleep $time;

    }

    return 0;

}


# --------------------------------------------
#
#   Subroutine NOTIFY_FOR_BUG
#
# --------------------------------------------
#
#   A notification will be displayed whenever 
#   the status of a bug has changed
#
# --------------------------------------------
#
#   -> args: HASHREF
#       bugid: bug ID
#       time: query time to the DB
#       sound: notification tone
#       debug: debug mode
#       nogreeting: dont display greeting
#
#   <- status: SCALAR
#       Exit Status. 0 (Success) or 1 (Failure).
#       Unix convention.
#
# --------------------------------------------


sub notify_for_bug {

    my $args = shift;

    $time  = $args->{time};
    $sound = $args->{sound};
    $debug = $args->{debug};


    if ( not $args->{nogreeting} ) { notify_greeting(); }


    Debugger::display_message(
        message  => "Starting notifier on bug: $args->{bugid}",
        type     => 'info',
        activate => $debug
    );


    if ( $time < MIN_TIME_PER_QUERY ) {

        Debugger::display_message(
            message  => 'A very short time has been set for queries to the DB',
            type     => 'warning',
            activate => $debug
        );

        $time = 30;

    }


    # As long as the bug exists 

    my $bug;
    my $bd = BugDao->new;

    while ( ( $bug = $bd->get_bug_by_id($args->{bugid}) ) &&
            $session_is_active ) {

        notify_bug_status( $bug );


        Debugger::display_message(
            message  => sprintf( 'Sleeping for %d seconds before continuing with bug %d', $time, $bug->get_id ),
            type     => 'info',
            activate => $debug
        );


        sleep $time;

    }


    if ( not $bug ) {
        print "Bug does not exist\n";
        return 1;
    }


    return 0;

}


# --------------------------------------------
#
#   Subroutine NOTIFY_GREETING
#
# --------------------------------------------
#
#   A greeting notification will be displayed
#
# --------------------------------------------
#
#   <- status:
#       completion status. 1 (Success) or 0 (Failure)
#
# --------------------------------------------


sub notify_greeting {

    # Build base notification

    my $username = $ENV{USER};
    my $header = "Welcome $username! I'm sister Lucia Bellucci";
    my $body = 'I will notify you when the lord contacts me. If you have any questions, run: ./lucia-notify --help';

    # Notify

    $notify->set_header($header);
    $notify->set_body($body);
    $notify->set_sound($sound);
    $notify->notify;


    return 1;

}


# --------------------------------------------
#
#   Subroutine NOTIFY_BUG_STATUS
#
# --------------------------------------------
#
#   Notify when bug changes state.
#
# --------------------------------------------
#
#   -> bug: HASH 
#
#   <- status:
#       completion status. 1 (Success) or 0 (Failure)
#
# --------------------------------------------


sub notify_bug_status {

    my $bug = shift;


    # check if the bug is already being used

    if ( not exists $tmp_bug_states{$bug->get_id} ) {

        set_temporary_bug_status( $bug->get_id, $bug->get_status );

        Debugger::display_message(
            message  => sprintf( 'A new bug %d with status %s has been added to the temporary DB', $bug->get_id, $bug->get_status ),
            type     => 'success',
            activate => $debug
        );

    }


    # check if the previous bug status is the same as recently obtained.
    # It will also exit if the status is closed

    my $bug_old_status = $tmp_bug_states{$bug->get_id};
    my $bug_current_status = $bug->get_status;

    return if $bug_old_status eq $bug_current_status ||
              $bug_current_status eq 'CLOSED';


    Debugger::display_message(
        message  => sprintf( 'Bug %d has %s status', $bug->get_id, $bug_current_status),
        type     => 'info',
        activate => $debug
    );


    # Assembly of header and body for the notification. 
    # The alias of the bug status is needed.

    my $bug_alias = get_alias_from_bug_status(
        tester     => $bug->get_rep_platform,
        resolution => $bug->get_resolution,
        status     => $bug_current_status
    );


    Debugger::display_message(
        message  => sprintf( 'Bug %d has been assigned alias %s', $bug->get_id, $bug_alias ),
        type     => 'success',
        activate => $debug
    );


    my $header = sprintf 'Bug #%d - %s', $bug->get_id, $bug->get_description;
    my $body   = sprintf 'God has notified me! The bug status is %s. ', $bug_current_status;
    $body     .= $bug_alias ? sprintf 'So the bug is %s.', $bug_alias :
                              'I\'m not sure what status it has on the board.';

    $notify->set_header($header);
    $notify->set_body($body);
    $notify->set_urgency(Notify::URGENCY);
    $notify->set_sound($sound);
    $notify->notify;


    Debugger::display_message(
        message  => sprintf( 'Bug %d notification was sent', $bug->get_id ),
        type     => 'success',
        activate => $debug
    );


    # The status in the temporary bugs table is updated

    $tmp_bug_states{$bug->get_id} = $bug_current_status;


    Debugger::display_message(
        message  => sprintf( 'Changed status of bug %d to: %s', $bug->get_id, $bug_current_status ),
        type     => 'success',
        activate => $debug
    );


    return 1;

}


# --------------------------------------------
#
#   Subroutine SET_TEMPORARY_BUG_STATUS
#
# --------------------------------------------
#
#   Temporarily stores the bug status in a 
#   status hash
#
#   Example: ( 17111 => 'NEW', 15411 => 'ASSIGNED' )
#
# --------------------------------------------
#
#   -> bug_id: INTEGER
#   -> bug_status: STRING
#
#   <- status:
#       completion status. 1 (Success) or 0 (Failure)
#
# --------------------------------------------


sub set_temporary_bug_status {

    my ( $bug_id, $bug_status ) = @_;

    $tmp_bug_states{$bug_id} = $bug_status;

    Debugger::display_message(
        message  => sprintf( 'Added bug %d to temporary DB', $bug_id ),
        type     => 'success',
        activate => $debug
    );

    return 1;

}


# --------------------------------------------
#
#   Subroutine GET_ALIAS_FROM_BUG_STATUS 
#   
# --------------------------------------------
#
#   Get a fictitious name corresponding to 
#   the Dev Board for the bug status
#
# --------------------------------------------
#
#   -> tester: STRING 
#   -> resolution: STRING
#   -> status: STRING
#
#   <- alias: STRING
#       Fictitious name of the Dev Board
#
# --------------------------------------------


sub get_alias_from_bug_status {

    my %args = @_;
    my ( $tester, $resolution, $status ) = @args{qw/tester resolution status/};


    return 'READY FOR DEV' if $status eq 'NEW'      || $status eq 'REOPENED';
    return 'IN DEV'        if $status eq 'ASSIGNED';
    return 'READY FOR QA'  if $status eq 'RESOLVED' && $resolution eq 'FIXED';
    return 'IN QA'         if $status eq 'RESOLVED' && $resolution eq 'FIXED' && $tester ne 'Sin Asignar';
    return 'DONE'          if $status eq 'VERIFIED' && $resolution eq 'FIXED';
    return 'AWAITING'      if $status eq 'REOPENED-MERGE';
    return;

}


1;

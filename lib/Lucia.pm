package Lucia;

use strict;
use warnings;

use Notify;
use Debugger;
use Translate;

use lib './lib/models';
use BugDao;
use UserDao;

use lib './modules/prototts';
use ProtoTTS;



use constant {

    MIN_TIME_PER_QUERY     => 10,
    SPANISH_VOICE          => 'Lucia',
    SPANISH_LANG           => 'es',

    DEFAULT_TIME_PER_QUERY => 30,
    DEFAULT_SOUND          => 0,
    DEFAULT_VOICE          => 0,
    DEFAULT_LANGUAGE       => 'en',
    DEFAULT_DEBUG          => 0,
    DEFAULT_NO_GREETING    => 0

};


sub new {

    my ($class, %args) = @_;

    my $self = {

        _time       => $args{time}       || DEFAULT_TIME_PER_QUERY,
        _sound      => $args{sound}      || DEFAULT_SOUND,
        _voice      => $args{voice}      || DEFAULT_VOICE,
        _lang       => $args{lang}       || DEFAULT_LANGUAGE,
        _debug      => $args{debug}      || DEFAULT_DEBUG,
        _nogreeting => $args{nogreeting} || DEFAULT_NO_GREETING,

        _notify     => Notify->new,
        _prototts   => ProtoTTS->new,

        _tmp_bug    => {}

    };

    $self->{_time} = $self->{_time} < MIN_TIME_PER_QUERY ? DEFAULT_TIME_PER_QUERY : $self->{_time};

    return bless $self, $class;

}


# --------------------------------------------
#
#   METHOD notify_for_testing 
#
# --------------------------------------------     
#
#   [Description]
# 
#   Send a test notification
#
# --------------------------------------------
#
#   @param self -> object
#
#   @return status -> integer: Returns 1 (successful) execution
#
# --------------------------------------------


sub notify_for_testing {

    my $self = shift;

    $self->_send_notification(
        header => Translate::translate_term( 'TEXT_TESTING_HEADER', $self->{_lang} ),
        body   => Translate::translate_term( 'TEXT_TESTING_BODY', $self->{_lang} ),
        sound  => $self->{_sound},
        debug  => $self->{_debug}
    );

    if ( $self->{_voice} ) {

        my $message = Translate::translate_term 'VOICE_TESTING', $self->{_lang};

        $self->_play_voice( $message );

    }

    Debugger::display_message
        message  => 'Test notification has been sent',
        type     => 'success',
        activate => $self->{_debug}
    ;

    return 1;

}


# --------------------------------------------
#
#   METHOD notify_for_bugs
#
# --------------------------------------------     
#
#   [Description]
# 
#   Runs a status change track for bugs found in a given time interval, and sends a notification if a change occurs.
#
# --------------------------------------------
#   
#   @param self -> object
#   @param bugs_string -> string: String containing a comma-separated list of bug identifiers. This param is required.
#
#   @return status -> integer: Returns 0 (failure) or 1 (successful) execution
#
# --------------------------------------------


sub notify_for_bugs {

    my ( $self, $bugs_string ) = @_;

    $self->_notify_greeting if not $self->{_nogreeting};

    if ( ! defined $bugs_string || $bugs_string !~ m/^(?:\d+,?)+$/ ) {
        print 'String undefined or invalid';
        return 0;
    }

    Debugger::display_message
        message  => sprintf( 'The following IDs will be used: %s', $bugs_string ),
        type     => 'info',
        activate => $self->{_debug}
    ;

    # In the event that bugs that were set are eliminated
    # or do not exist, they will be deleted from the array.
    # The loop will end once the array is empty.

    my @bugs;
    my $bd = BugDao->new;

    while ( @bugs = grep { defined }
                    map  { $bd->get_bug_by_id( $_ ) }
                    split /,/, $bugs_string ) {

        foreach my $bug ( @bugs ) { $self->_alert_on_bug_status_change( $bug ); }

        Debugger::display_message
            message  => sprintf( 'Sleeping for %d seconds before continuing to check for bugs', $self->{_time} ),
            type     => 'info',
            activate => $self->{_debug}
        ;

        sleep $self->{_time};

    }

    if ( not @bugs ) {
        print "There are no bugs for this user\n";
        return 0;
    }

    return 1;

}


# --------------------------------------------
#
#   METHOD notify_for_user_bugs
#
# --------------------------------------------     
#
#   [Description]
# 
#   This subroutine looks for bugs associated with a specific user and notifies them when there is a change in their status.
#
# --------------------------------------------
#   
#   @param self -> object
#   @param username -> string: Username for which bugs will be searched. This param is required.
#
#   @return status -> integer: Returns 0 (failure) or 1 (successful) execution
#
# --------------------------------------------


sub notify_for_user_bugs {

    my ( $self, $username ) = @_;

    $self->_notify_greeting if not $self->{_nogreeting};

    my $ud = UserDao->new;
    my $user = $ud->get_user_by_username( $username );

    if ( not $user ) {
        print "User does not exist\n";
        return 0;
    }

    Debugger::display_message
        message  => sprintf( 'Getting bugs from user %s', $username ),
        type     => 'info',
        activate => $self->{_debug}
    ;

    my $bugs;
    my $bd = BugDao->new;

    # Loop that will always listen for new bugs for the user

    while ( 1 ) {

        $bugs = $bd->get_bugs_by_userid( $user->get_id );

        next unless @$bugs;
        foreach my $bug (@$bugs) {  $self->_alert_on_bug_status_change( $bug ); }


        Debugger::display_message
            message  => sprintf( 'Sleeping for %d seconds before continuing to check for bugs by user %s', $self->{_time}, $username ),
            type     => 'info',
            activate => $self->{_debug}
        ;


        sleep $self->{_time};

    }

    return 1;

}


# --------------------------------------------
#
#   METHOD notify_for_bug
#
# --------------------------------------------     
#
#   [Description]
# 
#   Subroutine that notifies about changes in the status of a specific bug
#
# --------------------------------------------
#
#   @param self -> object
#   @param bugid -> integer: Bug ID to monitor. This param is required.
#
#   @return status -> integer: Returns 1 (failure) or 0 (successful) execution
#
# --------------------------------------------


sub notify_for_bug {

    my ( $self, $bugid ) = @_;

    $self->_notify_greeting if not $self->{_nogreeting};

    Debugger::display_message
        message  => "Starting notifier on bug: $bugid",
        type     => 'info',
        activate => $self->{_debug}
    ;

    # As long as the bug exists 

    my $bug;
    my $bd = BugDao->new;

    while ( $bug = $bd->get_bug_by_id( $bugid ) ) {

        $self->_alert_on_bug_status_change( $bug );

        Debugger::display_message
            message  => sprintf( 'Sleeping for %d seconds before continuing with bug %d', $self->{_time}, $bug->get_id ),
            type     => 'info',
            activate => $self->{_debug}
        ;

        sleep $self->{_time};

    }

    if ( not $bug ) {
        print "Bug does not exist\n";
        return 0;
    }

    return 1;

}


# --------------------------------------------
#
#   METHOD _notify_greeting
#
# --------------------------------------------     
#
#   [Description]
# 
#   A welcome notification will be displayed to the user
#
# --------------------------------------------
#
#   @param self -> object
#
#   @return status -> integer: Returns 1 per successful execution
#
# --------------------------------------------


sub _notify_greeting {

    my $self = shift;

    # Build base notification

    my $username = $ENV{USER};
    my $header = sprintf Translate::translate_term( 'TEXT_GREETING_NOTIFY_HEADER', $self->{_lang} ), $username;
    my $body = Translate::translate_term 'TEXT_GREETING_NOTIFY_BODY', $self->{_lang};
    my $icon = 'icons/warn.png';

    # Notify

    $self->_send_notification(
        header => $header,
        body   => $body,
        icon   => $icon,
        sound  => $self->{_sound}
    );

    if ( $self->{_voice} ) {

        my $message = sprintf Translate::translate_term( 'VOICE_GREETING', $self->{_lang} ), $username;

        $self->_play_voice( $message );

    }

    return 1;

}


# --------------------------------------------
#
#   METHOD _alert_on_bug_status_change
#
# --------------------------------------------     
#
#   [Description]
# 
#   The subroutine is used to notify the user when the bug status changes
#
# --------------------------------------------
#   
#   @param self -> object
#   @param bug -> Bug: Bug which information will be used for notification
#
#   @return status -> integer: Returns 1 per successful execution
#
# --------------------------------------------


sub _alert_on_bug_status_change {

    my ( $self, $bug ) = @_;

    # check if the bug is already being used

    if ( not exists $self->{_tmp_bug}->{$bug->get_id} ) {

        $self->{_tmp_bug}->{$bug->get_id} = $bug;

        Debugger::display_message
            message  => sprintf( 'Added bug %d to temporary DB', $bug->get_id ),
            type     => 'success',
            activate => $self->{_debug}
        ;

        Debugger::display_message
            message  => sprintf( 'A new bug %d with status %s has been added to the temporary DB', $bug->get_id, $bug->get_status ),
            type     => 'success',
            activate => $self->{_debug}
        ;

    }


    # check if the previous bug status and tester is the same as 
    # recently obtained. It will also exit if the status is closed.

    my $old_bug = $self->{_tmp_bug}->{$bug->get_id};

    return if ( $old_bug->get_status eq $bug->get_status &&
                $old_bug->get_rep_platform eq $bug->get_rep_platform ) ||
                $bug->get_status eq 'CLOSED';

    Debugger::display_message
        message  => sprintf( 'Bug %d has %s status', $bug->get_id, $bug->get_status),
        type     => 'info',
        activate => $self->{_debug}
    ;

    # Assembly of header and body for the notification. 
    # The alias of the bug status is needed.

    my $bug_alias = $self->_get_alias_from_bug_status(
        tester     => $bug->get_rep_platform,
        resolution => $bug->get_resolution,
        status     => $bug->get_status
    );

    Debugger::display_message
        message  => sprintf( 'Bug %d has been assigned alias %s', $bug->get_id, $bug_alias ),
        type     => 'success',
        activate => $self->{_debug}
    ;

    my $header = sprintf Translate::translate_term( 'TEXT_BUG_NOTIFY_HEADER', $self->{_lang} ),
                        $bug->get_id,
                        $bug->get_description;

    my $body = sprintf Translate::translate_term( 'TEXT_BUG_NOTIFY_BODY_1', $self->{_lang} ),
                        $bug->get_status,
                        $bug->get_resolution,
                        $bug->get_rep_platform;

    $body .= $bug_alias ? sprintf Translate::translate_term( 'TEXT_BUG_NOTIFY_BODY_2', $self->{_lang} ), $bug_alias :
                           Translate::translate_term 'TEXT_BUG_NOTIFY_BODY_3', $self->{_lang};

    my $icon = 'icons/notified.png';


    $self->_send_notification(
        header   => $header,
        body     => $body,
        icon     => $icon,
        urgency  => Notify::URGENCY,
        sound    => $self->{_sound}
    );

    if ($self->{_voice}) {

        my $message = sprintf Translate::translate_term( 'VOICE_BUG_NOTIFY', $self->{_lang} ),
                        $bug->get_id,
                        $bug_alias;

        $self->_play_voice( $message );

    }

    Debugger::display_message
        message  => sprintf( 'Bug %d notification was sent', $bug->get_id ),
        type     => 'success',
        activate => $self->{_debug}
    ;

    # The status in the temporary bugs table is updated

    $self->{_tmp_bug}->{$bug->get_id} = $bug;

    Debugger::display_message
        message  => sprintf( 'Changed status of bug %d to: %s', $bug->get_id, $bug->get_status ),
        type     => 'success',
        activate => $self->{_debug}
    ;

    return 1;

}


# --------------------------------------------
#
#   METHOD _get_alias_from_bug_status
#
# --------------------------------------------     
#
#   [Description]
# 
#   Gets an alias for the bug state
#
# --------------------------------------------
#   
#   @param self -> object
#   @param args -> hash
#     - tester -> string: Tester assigned to the bug
#     - resolution -> string: Current bug resolution
#     - status -> string: Current status of the resolution
# 
#   @return alias -> string: Alias for the bug status
#
# --------------------------------------------


sub _get_alias_from_bug_status {

    my ( $self, %args ) = @_;
    my ( $tester, $resolution, $status ) = @args{qw/tester resolution status/};

    my %status_aliases = (
        'NEW'       => Translate::translate_term( 'TEXT_NEW_ALIAS', $self->{_lang} ),
        'REOPENED'  => Translate::translate_term( 'TEXT_REOPENED_ALIAS', $self->{_lang} ),
        'ASSIGNED'  => Translate::translate_term( 'TEXT_ASSIGNED_ALIAS', $self->{_lang} ),
        'RESOLVED'  => {
            'FIXED' => {
                'Sin Asignar' => Translate::translate_term( 'TEXT_RESOLVED_FIXED_ALIAS_1', $self->{_lang} ),
                'Asignado'    => Translate::translate_term( 'TEXT_RESOLVED_FIXED_ALIAS_2', $self->{_lang} ),
            },
        },
        'VERIFIED'  => {
            'FIXED' => Translate::translate_term( 'TEXT_VERIFIED_FIXED_ALIAS', $self->{_lang} ),
        },
        'REOPENED-MERGE' => Translate::translate_term( 'TEXT_REOPENED_MERGE_ALIAS', $self->{_lang} ),
    );

    my $alias = $status_aliases{$status};

    if ( ref( $alias ) eq 'HASH' ) {
        $alias = $alias->{$resolution};
        if ( ref( $alias ) eq 'HASH' ) {
            $alias = $alias->{$tester} // $alias->{Asignado};
        }
    }

    return $alias;

}


# --------------------------------------------
#
#   METHOD _send_notification
#
# --------------------------------------------     
#
#   [Description]
# 
#   Send a notification through the notification library
#
# --------------------------------------------
#
#   @param self -> object
#   @param args -> hash:
#     - header -> string: Title of the notification. This param is optional.
#     - body -> string: Body of the notification. This param is optional.
#     - icon -> string: Icon for the application. This param is optional.
#     - urgency -> string: Urgency of the notification. This param is optional.
#     - sound -> integer: Sound for notification. This param is optional.
#
#   @return status -> integer: Returns 1 per successful execution 
#
# --------------------------------------------


sub _send_notification {

    my ( $self, %args ) = @_;

    my $notify = $self->{_notify};

    $notify->set_header( $args{header} )   if $args{header};
    $notify->set_body( $args{body} )       if $args{body};
    $notify->set_app_icon( $args{icon} )   if $args{icon};
    $notify->set_urgency( $args{urgency} ) if $args{urgency};
    $notify->set_sound( $args{sound} )     if $args{sound};
    $notify->notify;

    return 1;

}


# --------------------------------------------
#
#   METHOD _play_voice
#
# --------------------------------------------     
#
#   [Description]
# 
#   Plays a message using the Proto Text-To-Speech (ProtoTTS) module
#
# --------------------------------------------
#
#   @param self -> object
#   @param message -> string: the message to be played using TTS.
#
#   @return status -> integer: Returns 1 (successful) execution
#
# --------------------------------------------


sub _play_voice {

    my ( $self, $message ) = @_;

    my $prototts = $self->{_prototts};
    $prototts->set_message( $message );
    $prototts->set_voice( SPANISH_VOICE ) if $self->{_lang} eq SPANISH_LANG;
    $prototts->play;

    return 1;

}


1;

package Lucia::Core;

use strict;
use warnings;

use Lucia::ProtoTTS;
use Lucia::Dictionary;
use Lucia::Debugger qw(success warning failure info);
use Lucia::Notification::Notify;
use Lucia::BugChurch::Proxy;
use Lucia::Events;
use Lucia::BookStorage;
use Lucia::Utils::File qw(get_resources_dir);
use Lucia::Utils::Language qw(lang_exists);


use constant {

    DEFAULT_TIME_PER_QUERY => 30,
    DEFAULT_SOUND          => 0,
    DEFAULT_VOICE          => 0,
    DEFAULT_LANGUAGE       => 'en',
    DEFAULT_DEBUG          => 0,
    DEFAULT_NO_GREETING    => 0,

    MIN_TIME_PER_QUERY     => 10,

};


sub new {

    my ( $class, %args ) = @_;

    my $self = {

        _time          => DEFAULT_TIME_PER_QUERY,
        _sound         => DEFAULT_SOUND,
        _debug         => DEFAULT_DEBUG,
        _nogreeting    => DEFAULT_NO_GREETING,
        _lang          => DEFAULT_LANGUAGE,
        _voice_engine  => undef,

        _bcp           => Lucia::BugChurch::Proxy->new,
        _notify        => Lucia::Notification::Notify->new,

        _evt           => Lucia::Events->new,
        _current_evt   => undef,

        _resources_dir => get_resources_dir(),

    };

    bless $self, $class;

    $self->_load_dictionary;

    return $self;

}

sub _load_dictionary {

    my $self = shift;

    my $lang = $self->{_lang};
    $self->{_dict} = Lucia::Dictionary->new;
    $self->{_dict}->set_lang($lang);

    return;

}

sub set_time {

    my ( $self, $time ) = @_;

    die "[x] That time is nonsense, something coherent please\n"
        unless $time >= MIN_TIME_PER_QUERY;
    $self->{_time} = $time;

    return;

}

sub set_lang {

    my ( $self, $lang ) = @_;

    die "[x] I don't know that language.\n" unless lang_exists($lang);
    $self->{_lang} = $lang;
    $self->{_dict}->set_lang($lang);

    return;

}

sub enable_sound {

    my $self = shift;
    $self->{_sound} = 1;
    return;

}

sub enable_voice {

    my $self = shift;
    $self->{_voice_engine} = Lucia::ProtoTTS->new;
    return;

}

sub enable_debug {

    my $self = shift;
    $self->{_debug} = 1;
    return;

}

sub enable_no_greeting {

    my $self = shift;
    $self->{_nogreeting} = 1;
    return;

}

sub notify_for_bugs {

    my ( $self, $bugs_string ) = @_;

    $self->_create_book_storage;

    die "[x] bugs string is undefined or invalid\n"
        unless defined $bugs_string && $self->_bugs_string_is_valid($bugs_string);

    $self->_notify_greeting unless $self->{_nogreeting};

    Lucia::Debugger::info("The following IDs will be used: $bugs_string")
        if $self->{_debug};

    my @bugs;
    my $bcp = $self->{_bcp};
    $bcp->use_model('bug');

    while ( @bugs = @{ $bcp->get_bugs_by_ids($bugs_string) } ) {
        foreach my $bug (@bugs) {
            # Save the bug if it doesn't exist
            if ( ! $self->{_book_storage}->bug_exists($bug->get_id) ) {
                $self->{_book_storage}->save_bug($bug);

                Lucia::Debugger::success(
                    sprintf("The bug %s has been saved in the Lucia's Book with status %s",
                    $bug->get_id, $bug->get_status)
                ) if $self->{_debug};

                next;
            }

            # Skip processing if bug status and tester platform remain the same
            if ( $self->_bug_has_same_status($bug->get_id, $bug->get_status) &&
                 $self->_tester_is_the_same($bug->get_id, $bug->get_rep_platform) ) {

                Lucia::Debugger::warning(
                    sprintf(
                        'Skipping iteration because bug %s or tester status has not changed',
                        $bug->get_id
                    )
                ) if $self->{_debug};

                next;
             }

            # Alert about the bug change and save the bug
            $self->_alert_change($bug);
            $self->{_book_storage}->save_bug($bug);

            Lucia::Debugger::success(
                sprintf("The bug %s has been updated in the Lucia's Book with status %s",
                $bug->get_id, $bug->get_status)
            ) if $self->{_debug};
        }

        Lucia::Debugger::info(
            sprintf(
                'Sleeping for %d seconds before continuing to check for bugs',
                $self->{_time}
            )
        ) if $self->{_debug};

        $self->_wait_time_for_notification();
    }

    print "[x] There are no bugs to work on.\n";

    return;

}

sub notify_for_user {

    my ( $self, $username ) = @_;

    $self->_create_book_storage;

    $self->_notify_greeting unless $self->{_nogreeting};

    my @bugs;

    my $bcp = $self->{_bcp};

    $bcp->use_model('user');
    my $user = $bcp->get_user_by_username($username);
    die "[x] User does not exist\n" unless $user;

    Lucia::Debugger::info("Getting bugs from user $username")
        if $self->{_debug};

    $bcp->use_model('bug');

    while ( 1 ) {

        my $skip_assign_notification = $self->{_book_storage}->is_new;

        $self->_wait_time_for_notification;

        @bugs = @{$bcp->get_bugs_by_userid($user->get_id)};
        $self->_delete_cached_bugs_from_book(\@bugs);

        if ( !@bugs ) {
            Lucia::Debugger::warning(
                sprintf('There are no bugs available for %s', $username)
            ) if $self->{_debug};
            next;
        };

        foreach my $bug ( @bugs ) {
            # Save the bug if it doesn't exist
            if ( ! $self->{_book_storage}->bug_exists($bug->get_id) ) {
                $self->{_book_storage}->save_bug($bug);
                $self->_alert_new_assign($bug) unless $skip_assign_notification;

                Lucia::Debugger::success(
                    sprintf("The bug %s has been saved in the Lucia's Book with status %s",
                    $bug->get_id, $bug->get_status)
                ) if $self->{_debug};

                next;
            }

            # Skip processing if bug status and tester platform remain the same
            if ( $self->_bug_has_same_status($bug->get_id, $bug->get_status) &&
                 $self->_tester_is_the_same($bug->get_id, $bug->get_rep_platform) ) {
                Lucia::Debugger::warning(
                    sprintf(
                        'Skipping iteration because bug %s or tester status has not changed',
                        $bug->get_id
                    )
                ) if $self->{_debug};

                next;
             }

            # Alert about the bug change and update the bug
            $self->{_book_storage}->save_bug($bug);
            $self->_alert_change($bug);

            Lucia::Debugger::success(
                sprintf("The bug %s has been updated in the Lucia's Book with status %s",
                $bug->get_id, $bug->get_status)
            ) if $self->{_debug};
        };

        if($skip_assign_notification){
            $self->{_book_storage}->enable_used_book;
            $self->{_book_storage}->update_book;
        };

        Lucia::Debugger::info(
            sprintf(
                'Sleeping for %d seconds before continuing to check for bugs',
                $self->{_time}
            )
        ) if $self->{_debug};
    }

    return;

}

sub _create_book_storage {

    my $self = shift;
    $self->{_book_storage} = Lucia::BookStorage->new;
    return;

}

sub _notify_greeting {

    my $self = shift;

    my $username = $ENV{USER};
    my $header = $self->{_dict}->get_formatted_definition('TEXT_GREETING_NOTIFY_HEADER', [$username]);
    my $body = $self->{_dict}->get_formatted_definition('TEXT_GREETING_NOTIFY_BODY');

    $self->_send_notification(
        header => $header,
        body   => $body,
    );

    if ( $self->{_voice_engine} && !$self->{_current_evt}) {
        my $message = $self->{_dict}->get_formatted_definition('VOICE_GREETING', [$username]);
        $self->_play_voice($message);
    }

}

sub _bug_has_same_status {

    my ( $self, $bug_id, $current_bug_status ) = @_;
    my $old_bug = $self->{_book_storage}->get_bug_by_id($bug_id);
    return $old_bug->get_status eq $current_bug_status;

}

sub _tester_is_the_same {

    my ( $self, $bug_id, $current_tester ) = @_;

    my $old_bug = $self->{_book_storage}->get_bug_by_id($bug_id);
    my $old_tester = $old_bug->get_rep_platform;
    return $old_tester eq $current_tester;

}

sub simulate {

    my ( $self, $bugs_string ) = @_;

    die "[x] bugs string is undefined or invalid\n"
        unless defined $bugs_string && $self->_bugs_string_is_valid($bugs_string);

    my @bug_ids = split /,/, $bugs_string;

    foreach my $bug_id (@bug_ids) {
        $self->_wait_random_time_for_notification;
        my $bug = $self->_create_dummy_bug($bug_id);
        $self->_alert_change($bug);
    }

    return;

}

sub _delete_cached_bugs_from_book {

    my ( $self, $bugs ) = @_;

    my @book_bug_ids = $self->{_book_storage}->get_bug_ids;
    my %db_bug_ids = map { $_->get_id => 1 } @$bugs;

    # If there is a bug in the local db that is no
    # longer found in the external db, delete it.

    foreach my $bug_id ( @book_bug_ids ) {
        if (!exists $db_bug_ids{$bug_id}) {
            $self->{_book_storage}->delete_bug_by_id($bug_id);
        }
    }

    $self->{_book_storage}->update_book;

    return;

}

sub _alert_new_assign {

    my ( $self, $bug ) = @_;

    my $header = $self->{_dict}->get_formatted_definition('TEXT_BUG_NOTIFY_NEW_ASSIGN_HEADER', [ $bug->get_id ]);
    my $body = $self->{_dict}->get_formatted_definition('TEXT_BUG_NOTIFY_NEW_ASSIGN_BODY');

    $self->_send_notification(
        header => $header,
        body   => $body,
    );

    if ($self->{_voice_engine} && !$self->{_current_evt}) {
        my $message = $self->{_dict}->get_formatted_definition('VOICE_BUG_NOTIFY_NEW_ASSIGN');
        $self->_play_voice($message);
    }

    return;

}

sub _alert_change {

    my ( $self, $bug ) = @_;

    my $bug_alias = $self->_create_alias_for_bug_status(
        tester     => $bug->get_rep_platform,
        resolution => $bug->get_resolution,
        status     => $bug->get_status
    );

    my $header = $self->{_dict}->get_formatted_definition('TEXT_BUG_NOTIFY_HEADER', [ $bug->get_id, $bug->get_description ]);
    my $body = $self->{_dict}->get_formatted_definition('TEXT_BUG_NOTIFY_BODY_1', [ $bug->get_status, $bug->get_resolution, $bug->get_rep_platform ]);
    $body .= $bug_alias ? $self->{_dict}->get_formatted_definition('TEXT_BUG_NOTIFY_BODY_2', [$bug_alias])
                        : $self->{_dict}->get_formatted_definition('TEXT_BUG_NOTIFY_BODY_3');

    $self->_send_notification(
        header => $header,
        body   => $body,
    );

    if ($self->{_voice_engine} && !$self->{_current_evt}) {
        my $message = $self->{_dict}->get_formatted_definition('VOICE_BUG_NOTIFY', [ $bug->get_id, $bug_alias ]);
        $self->_play_voice($message);
    }

    return;

}

sub _create_alias_for_bug_status {

    my ( $self, %args ) = @_;

    my $tester     = $args{tester};
    my $resolution = $args{resolution};
    my $status     = $args{status};

    my %status_aliases = (
        'NEW'      => $self->{_dict}->get_formatted_definition('TEXT_NEW_ALIAS'),
        'REOPENED' => $self->{_dict}->get_formatted_definition('TEXT_REOPENED_ALIAS'),
        'ASSIGNED' => $self->{_dict}->get_formatted_definition('TEXT_ASSIGNED_ALIAS'),
        'RESOLVED' => {
            'FIXED' => {
                'Sin Asignar' => $self->{_dict}->get_formatted_definition('TEXT_RESOLVED_FIXED_ALIAS_1'),
                'Asignado' => $self->{_dict}->get_formatted_definition('TEXT_RESOLVED_FIXED_ALIAS_2'),
            },
        },
        'VERIFIED' => {
            'FIXED' => $self->{_dict}->get_formatted_definition('TEXT_VERIFIED_FIXED_ALIAS'),
        },
        'REOPENED-MERGE' => $self->{_dict}->get_formatted_definition('TEXT_REOPENED_MERGE_ALIAS'),
    );

    my $alias = $status_aliases{$status};

    if ( ref $alias eq 'HASH' ) {
        $alias = $alias->{$resolution};
        if ( ref $alias eq 'HASH' ) {
            $alias = $alias->{$tester} // $alias->{Asignado};
        }
    }

    return $alias;

}

sub _bugs_string_is_valid {

    my ( $self, $bugs_string ) = @_;
    return $bugs_string =~ m/^(?:\d+,?)+$/;

}

sub _wait_random_time_for_notification {

    my $self = shift;
    my $random_time = int rand 10;
    $self->_wait_time_for_notification($random_time);
    return;

}

sub _wait_time_for_notification {

    my ( $self, $time ) = @_;
    sleep( $time || $self->{_time} );
    return;

}

sub _create_dummy_bug {

    my ( $self, $bug_id ) = @_;
    my $description  = $self->{_dict}->get_formatted_definition('TEXT_SIMULATE_DESCRIPTION');

    require Lucia::BugChurch::Entities::Bug;

    my $bug = Lucia::BugChurch::Entities::Bug->new;
    $bug->set_id($bug_id);
    $bug->set_status('RESOLVED');
    $bug->set_description($description);
    $bug->set_rep_platform('Emily');
    $bug->set_resolution('FIXED');

    return $bug;

}

sub _send_notification {

    my ( $self, %args ) = @_;

    my $notification = $self->{_notify};
    $notification->set_app_name('Lucia');

    $self->{_current_evt} = $self->{_evt}->get_current_event();

    my $icon = sprintf('%s/icons/%s', $self->{_resources_dir},
      $self->{_current_evt} ? $self->{_current_evt}->{icon} : "icon.png");
    $notification->set_app_icon($icon);

    $notification->set_header($args{header});
    $notification->set_body($args{body});

    if ($self->{_sound}) {
        my $sound_filename = sprintf('%s/sounds/%s', $self->{_resources_dir},
          $self->{_current_evt} ? $self->{_current_evt}->{sound} : "church_notification.ogg");
        $notification->set_sound($sound_filename);
    }

    $notification->notify;

    return;

}

sub _play_voice {

    my ( $self, $message ) = @_;

    my $prototts = $self->{_voice_engine};
    $prototts->set_message($message);
    $prototts->set_lang($self->{_lang});
    $prototts->play;

    return;

}

1;

package Lucia::Lucia;

use strict;
use warnings;

use Lucia::Defaults;
use Lucia::ProtoTTS;
use Lucia::Dictionary;
use Lucia::BugTrackerClient;
use Lucia::Notification::Notify;


our %LUCIA_VOICES = (
    es => 'Lucia',
    en => 'Kimberly'
);

sub new {

    my $class = shift;

    my $self = {

        _time         => DEFAULT_TIME_PER_QUERY,
        _voice_engine => undef,
        _sound        => DEFAULT_SOUND,
        _lang         => DEFAULT_LANGUAGE,
        _debug        => DEFAULT_DEBUG,
        _nogreeting   => DEFAULT_NO_GREETING,

        _tmp_bug      => {},
        
        _btc          => Lucia::BugTrackerClient->new( "localhost", 3000 ), 
        _notify       => Lucia::Notification::Notify->new,
        _dict         => Lucia::Dictionary->new

    };

    return bless $self, $class;

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
    $self->{_lang} = $lang;
    return;

}

sub active_sound {

    my ( $self, $is_active ) = @_;

    die "[x] Please provide 1 or 0\n" unless $is_active =~ /^[01]$/;
    $self->{_sound} = $is_active;

    return;

}

sub active_voice {

    my ( $self, $is_active ) = @_;

    die "[x] Please provide 1 or 0\n" unless $is_active =~ /^[01]$/;
    $self->{_voice_engine} = Lucia::ProtoTTS->new if $is_active;

    return;

}

sub set_language {

    my ( $self, $lang ) = @_;

    die "[x] I don't speak that language\n"
      unless exists $LUCIA_VOICES{$lang};
    $self->{_lang} = $lang;

    return;

}

sub active_debug {

    my ( $self, $is_active ) = @_;

    die "[x] Please provide 1 or 0\n" unless $is_active =~ /^[01]$/;
    $self->{_debug} = $is_active;

    return;

}

sub active_no_greeting {

    my ( $self, $is_active ) = @_;

    die "[x] Please provide 1 or 0\n" unless $is_active =~ /^[01]$/;
    $self->{_nogreeting} = $is_active;

    return;

}

sub notify_for_bugs {

    my ( $self, $bugs_string ) = @_;

    die "[x] bugs string is undefined or invalid\n"
      unless defined $bugs_string && $self->_bugs_string_is_valid( $bugs_string );

    $self->_notify_greeting unless $self->{_nogreeting};

    my @bugs;
    my $btc = $self->{_btc};

    while ( @bugs = @{$btc->get_bugs_by_ids( $bugs_string )} ) {

        foreach my $bug ( @bugs ) {

            $self->_save_bug( $bug ) unless $self->_bug_exists( $bug->get_id );

            next unless $self->_bug_status_has_changed( $bug->get_id, $bug->get_status );
            next unless $self->_tester_has_changed( $bug->get_id, $bug->get_rep_platform );
            next if $bug->get_status eq 'CLOSED';
 
            $self->_update_bug( $bug );
            $self->_alert_change( $bug );

        }

        $self->_wait_time_for_notification();

    }

    return;

}

sub notify_for_user {}

sub _notify_greeting {

    my $self = shift;
    
    my $username = $ENV{USER};
    my $header = $self->_create_message( 'TEXT_GREETING_NOTIFY_HEADER', [ $username ] );
    my $body = $self->_create_message( 'TEXT_GREETING_NOTIFY_BODY' );

    $self->_send_notification(
        header => $header,
        body   => $body,
    );

    if ( $self->{_voice_engine} ) {
        my $message = $self->_create_message( 'VOICE_GREETING', [ $username ] );
        $self->_play_voice($message);
    }

}

sub _bug_exists {

    my ( $self, $bug_id ) = @_;
    return exists $self->{_tmp_bug}->{$bug_id};

}

sub _save_bug {

    my ( $self, $bug ) = @_;
    $self->{_tmp_bug}->{$bug->get_id} = $bug;

}

sub _bug_status_has_changed {

    my ( $self, $bug_id, $current_bug_status ) = @_;

    my $old_bug = $self->{_tmp_bug}->{$bug_id};
    return $old_bug->get_status ne $current_bug_status;

}

sub _tester_has_changed {

    my ( $self, $bug_id, $current_tester ) = @_;

    my $old_bug = $self->{_tmp_bug}->{$bug_id};
    my $old_tester = $old_bug->get_rep_platform;
    return $old_tester ne $current_tester;

}

sub _update_bug {
    
    my ( $self, $bug ) = @_;
    $self->{_tmp_bug}->{$bug->get_id} = $bug;

}

sub _alert_change {
    
    my ( $self, $bug ) = @_;

    my $bug_alias = $self->_create_alias_for_bug_status(
        tester     => $bug->get_rep_platform,
        resolution => $bug->get_resolution,
        status     => $bug->get_status
    );

    my $header = $self->_create_message( 'TEXT_BUG_NOTIFY_HEADER', [ $bug->get_id, $bug->get_description ] );
    my $body = $self->_create_message( 'TEXT_BUG_NOTIFY_BODY_1', [ $bug->get_status, $bug->get_resolution, $bug->get_rep_platform ] );
    $body .= $bug_alias ? $self->_create_message( 'TEXT_BUG_NOTIFY_BODY_2', [ $bug_alias ] )
                        : $self->_create_message( 'TEXT_BUG_NOTIFY_BODY_3' );
    my $icon = 'icons/notified.png';

    $self->_send_notification(
        header => $header,
        body   => $body,
        icon   => $icon,
    );

    if ( $self->{_voice_engine} ) {
        my $message = $self->_create_message( 'VOICE_BUG_NOTIFY', [ $bug->{id}, $bug_alias ] );
        $self->_play_voice($message);
    }

    return; 

}

sub _create_alias_for_bug_status {

    my ( $self, %args ) = @_;

    my $tester = $args{tester};
    my $resolution = $args{resolution};
    my $status = $args{status};

    my %status_aliases = (
        'NEW'       => $self->_create_message( 'TEXT_NEW_ALIAS' ),
        'REOPENED'  => $self->_create_message( 'TEXT_REOPENED_ALIAS' ),
        'ASSIGNED'  => $self->_create_message( 'TEXT_ASSIGNED_ALIAS' ),
        'RESOLVED'  => {
            'FIXED' => {
                'Sin Asignar' => $self->_create_message( 'TEXT_RESOLVED_FIXED_ALIAS_1' ),
                'Asignado'    => $self->_create_message( 'TEXT_RESOLVED_FIXED_ALIAS_2' ),
            },
        },
        'VERIFIED'  => {
            'FIXED' => $self->_create_message( 'TEXT_VERIFIED_FIXED_ALIAS' ),
        },
        'REOPENED-MERGE' => $self->_create_message( 'TEXT_REOPENED_MERGE_ALIAS' ),
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

sub simulate {

    my ( $self, $bugs_string ) = @_;

    die "[x] bugs string is undefined or invalid\n"
      unless defined $bugs_string && $self->_bugs_string_is_valid( $bugs_string );

    my @bug_ids = split /,/, $bugs_string;

    foreach my $bug_id (@bug_ids) {

        $self->_wait_random_time_for_notification();

        my $bug = $self->_create_dummy_bug($bug_id);
            
        my $header = $self->_create_message( 'TEXT_BUG_NOTIFY_HEADER', [ $bug->{id}, $bug->{desc} ] );
        my $body = $self->_create_message( 'TEXT_BUG_NOTIFY_BODY_1', [ $bug->{status}, $bug->{resolution}, $bug->{tester} ] );
        $body .= $self->_create_message( 'TEXT_BUG_NOTIFY_BODY_2', [ $bug->{status_alias} ] );

        $self->_send_notification(
            header => $header,
            body   => $body,
        );

        if ( $self->{_voice_engine} ) {
            my $message = $self->_create_message( 'VOICE_BUG_NOTIFY', [ $bug->{id}, $bug->{status_alias} ] );
            $self->_play_voice($message);
        }

    }

    return;

}

sub _bugs_string_is_valid {

    my ( $self, $bugs_string ) = @_;
    return $bugs_string =~ m/^(?:\d+,?)+$/;

}

sub _wait_random_time_for_notification {

    my $self = shift;
    my $random_time = int rand 10;
    $self->_wait_time_for_notification( $random_time );
    return;

}

sub _wait_time_for_notification {

    my ( $self, $time ) = @_;
    sleep( $time || $self->{_time} );
    return;

}

sub _create_dummy_bug {

    my ( $self, $bug_id ) = @_;

    my $description = $self->_create_message( 'TEXT_SIMULATE_DESCRIPTION' );
    my $status_alias = $self->_create_message( 'TEXT_REOPENED_ALIAS' );

    my $bug = {
        id           => $bug_id,
        desc         => $description,
        status       => 'REOPENED',
        resolution   => '',
        tester       => 'Emily',
        status_alias => $status_alias
    };

    return $bug;

}

sub _create_message {

    my ( $self, $term, $items ) = @_;

    my $lang = $self->{_lang};
    my $dict = $self->{_dict};

    my $message = $dict->get_definition( $term, $lang );

    if ( $items ) {
        my @items = @{ $items };
        $message = sprintf $message, @items;
    }

    return $message;

}

sub _send_notification {

    my ( $self, %args ) = @_;

    my $notification = $self->{_notify};

    $notification->set_app_name('Lucia');
    $notification->set_header( $args{header} );
    $notification->set_body( $args{body} );
    $notification->active_sound( $self->{_sound} );

    $notification->notify;

    return;

}

sub _play_voice {

    my ( $self, $message ) = @_;

    my $prototts = $self->{_voice_engine};
    $prototts->set_message($message);
    $prototts->set_voice( $LUCIA_VOICES{ $self->{_lang} } );
    $prototts->play;

    return;

}

1;

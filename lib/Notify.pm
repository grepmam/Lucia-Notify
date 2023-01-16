package Notify;

use strict;
use warnings;

use Cwd;
use File::Which;
use Net::DBus;


sub new {

    my $class = shift;

    my $self = {

        _app_name => '',
        _replace_id => 0,
        _app_icon => Cwd::abs_path('.') . '/icons/icon.png',
        _header => 'Hello! I am the nun Lucia',
        _body => 'This is a test of how I will notify you.',
        _actions => [],
        _hints => { urgency => 'critical' },
        _expire_timeout => 18000,
        _sound => 0,

    };

    # Create notification object with DBUS

    my $bus = Net::DBus->session;
    my $notify_service = $bus->get_service(
        'org.freedesktop.Notifications'
    );
    my $notify_object = $notify_service->get_object(
        '/org/freedesktop/Notifications',
        'org.freedesktop.Notifications'
    );

    $self->{_notif_obj} = $notify_object;

    return bless $self, $class;

}


sub set_app_name {

    my ($self, $app_name) = @_;
    $self->{_app_name} = $app_name;
    return;

}


sub set_replace_id {

    my ($self, $replace_id) = @_;
    $self->{_replace_id} = $replace_id;
    return;

}


sub set_app_icon {

    my ($self, $app_icon) = @_;
    $self->{_app_icon} = $app_icon;
    return;

}


sub set_header {

    my ($self, $header) = @_;
    $self->{_header} = $header;
    return;

}


sub set_body {

    my ($self, $body) = @_;
    $self->{_body} = $body;
    return;

}


sub set_action {

    my ($self, $action) = @_;
    #$self->{_} = $action;
    return;

}


sub set_hint {

    my ($self, $hint) = @_;
    $self->{_hint}->{urgency} = $hint;
    return;

}


sub set_expire_timeout {

    my ($self, $expire_timeout) = @_;
    $self->{_expire_timeout} = $expire_timeout;
    return;

}


sub set_sound {

    my ($self, $sound) = @_;
    $self->{_sound} = $sound;
    return;

}


sub notify {

    my $self = shift;
    my $sound = $self->{_sound};
    my $notify_object = $self->{_notif_obj};

    $notify_object->Notify(

        $self->{_app_name},
        $self->{_replace_id},
        $self->{_app_icon},
        $self->{_header},
        $self->{_body},
        $self->{_actions},
        $self->{_hints},
        $self->{_expire_timeout}

    );

    if ($sound) {

        my $paplay_path = which 'paplay';
        system $paplay_path,
        Cwd::abs_path('.') . '/sounds/church_notification.ogg';

    }

    return;

}


1;

package Notify;

use strict;
use warnings;

use Encode qw(decode);
use File::Which;
use Net::DBus;

use Utils;


use constant {

    LOW     => Net::DBus::dbus_byte(0),
    NORMAL  => Net::DBus::dbus_byte(1),
    URGENCY => Net::DBus::dbus_byte(2)

};


sub new {

    my $class = shift;

    my $self = {

        _app_name       => '',
        _replace_id     => 0,
        _app_icon       => Utils::get_abs_path( 'icons/icon.png' ),
        _header         => '',
        _body           => '',
        _actions        => [],
        _hints          => { 'urgency' => NORMAL },
        _expire_timeout => 25000,
        _sound          => 0

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
    $self->{_app_icon} = Utils::get_abs_path $app_icon;
    return;

}


sub set_header {

    my ($self, $header) = @_;
    $self->{_header} = decode 'cp1252', $header;
    return;

}


sub set_body {

    my ($self, $body) = @_;
    $self->{_body} = $body;
    return;

}


sub set_urgency {

    my ($self, $urgency) = @_;
    $self->{_hints}->{urgency} = $urgency;
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
        Utils::get_abs_path 'sounds/church_notification.ogg';

    }

    return;

}


1;

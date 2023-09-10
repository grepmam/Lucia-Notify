package Lucia::Notification::DBus;

use strict;
use warnings;

use Net::DBus;
use Encode qw(decode);
use Exporter qw(import);

use Lucia::Utils::File;


use constant {

    DBUS_SERVICE   => 'org.freedesktop.Notifications',
    DBUS_INTERFACE => 'org.freedesktop.Notifications',
    DBUS_PATH      => '/org/freedesktop/Notifications',

    #LOW_LEVEL      => Net::DBus::dbus_byte(0),
    #NORMAL_LEVEL   => Net::DBus::dbus_byte(1),
    #HIGH_LEVEL     => Net::DBus::dbus_byte(2),

    ENCODING       => 'cp1252'

};


sub new {

    my $class = shift;

    my $self = {
        _app_name       => '',
        _replace_id     => 0,
        _app_icon       => '',
        _header         => '',
        _body           => '',
        _actions        => [],
        _hints          => {},
        _expire_timeout => 25000,
    };

    my $bus = Net::DBus->session;
    my $notify_service = $bus->get_service( DBUS_SERVICE );
    my $notify_object = $notify_service->get_object( DBUS_PATH, DBUS_INTERFACE );

    $self->{_notif_obj} = $notify_object;

    return bless $self, $class;

}


sub set_app_name {

    my ( $self, $app_name ) = @_;
    $self->{_app_name} = $app_name;
    return;

}


sub set_replace_id {

    my ( $self, $replace_id ) = @_;
    $self->{_replace_id} = $replace_id;
    return;

}


sub set_app_icon {

    my ( $self, $app_icon ) = @_;
    $self->{_app_icon} = Lucia::Utils::File::absolute_path( $app_icon );
    return;

}


sub set_header {

    my ( $self, $header ) = @_;
    $self->{_header} = decode ENCODING, $header;
    return;

}


sub set_body {

    my ( $self, $body ) = @_;
    $self->{_body} = $body;
    return;

}


#sub set_urgency_level {
#
#    my ( $self, $level ) = @_;
#    $self->{_hints}{urgency} = $level;
#    return;
#
#}


sub set_expire_timeout {

    my ( $self, $expire_timeout ) = @_;

    die "[x] Time must be an integer\n" unless $expire_timeout =~ /^[0-9]+$/;
    $self->{_expire_timeout} = $expire_timeout * 1000;

    return;

}


sub launch_notification {

    my $self = shift;

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

    return;

}


1;

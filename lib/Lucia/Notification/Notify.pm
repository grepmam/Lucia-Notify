package Lucia::Notification::Notify;

use strict;
use warnings;

use File::Which;

use parent 'Lucia::Notification::DBus';


sub new {

    my $class = shift;

    my $self = $class->SUPER::new(@_);
    $self->{_app_icon} = Lucia::Utils::File::absolute_path( 'resources/icons/icon.png' );
    $self->{_hints}{urgency} = Lucia::Notification::DBus::HIGH_LEVEL;
    $self->{_sound} = 1;

    return bless $self, $class;

}


sub active_sound {

    my ( $self, $is_active ) = @_;
    die "[x] Please provide 1 or 0\n" unless $is_active =~ /^[01]$/;
    $self->{_sound} = $is_active;
    return;

}


sub notify {

    my $self = shift;
    my $sound = $self->{_sound};

    $self->launch_notification;
    $self->_play_sound if $sound;

    return;

}

sub _play_sound {

    my $self = shift;

    my $mpv_path = which 'mpv';
    my $sound_filename = Lucia::Utils::File::absolute_path( 'resources/sounds/church_notification.ogg' );
    system "$mpv_path --no-video $sound_filename > /dev/null 2>&1";

    return; 

}


1;

package Lucia::Notification::Notify;

use strict;
use warnings;

use File::Which qw(which);

use parent 'Lucia::Notification::DBus';


sub new {

    my ( $class, $resources ) = @_;

    my $self = $class->SUPER::new(@_);
    #$self->{_hints}{urgency} = Lucia::Notification::DBus::HIGH_LEVEL;
    $self->{_sound} = undef;

    return bless $self, $class;

}

sub set_sound {

    my ( $self, $sound ) = @_;
    die "[x] The sound file does not exist.\n" unless -e $sound;
    $self->{_sound} = $sound;

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
    my $sound_filename = $self->{_sound};
    system "$mpv_path --no-video $sound_filename > /dev/null 2>&1";

    return; 

}

1;

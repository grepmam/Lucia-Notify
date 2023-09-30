package Lucia::Events;

use strict;
use warnings;

use DateTime;


use constant {
    DATETIME_REGEX => qr/\d\d?-\d\d?/,
    DATETIME_TIME_ZONE => 'America/Argentina/Buenos_Aires'
};

our $EVENTS = {
    Christmas => {
        date  => ["01-12", "25-12"],
        icon  => ".events/christmas.png",
        sound => ".events/christmas.ogg",
    },
    Halloween => {
        date  => ["31-10"],
        icon  => ".events/halloween.png",
        sound => ".events/halloween.ogg",
    },
};


sub new {
    my $class = shift;
    return bless {}, $class;
}

sub _get_datetime_obj {
    my ($self, $datetime_str) = @_;

    die "[x] Datetime string must be in the following format: dd-mm (one digit per side allowed).\n"
        unless $datetime_str =~ DATETIME_REGEX;

    my ($day, $month) = split /-/, $datetime_str;

    my $datetime_obj = DateTime->new(
        year  => DateTime->now(time_zone => DATETIME_TIME_ZONE)->year,
        month => $month,
        day   => $day,
    );

    return $datetime_obj;
}

sub get_current_event {
    my $self = shift;

    my $current_date_obj = DateTime->now(
        time_zone => DATETIME_TIME_ZONE
    )->truncate(to => 'day');

    my $event;

    foreach my $event_name (keys %$EVENTS) {
        my ($min_date, $max_date) = @{$EVENTS->{$event_name}->{date}};
        my $min_date_obj = $self->_get_datetime_obj($min_date);
        my $max_date_obj = $max_date ? $self->_get_datetime_obj($max_date) : undef;

        return $EVENTS->{$event_name} if (
            (!$max_date && $current_date_obj == $min_date_obj) ||
            ($max_date && $current_date_obj >= $min_date_obj && $current_date_obj <= $max_date_obj)
        );

    }

    return;
}

1;

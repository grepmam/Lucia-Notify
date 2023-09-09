package Lucia::BugChurch::Entities::Bug;

use strict;
use warnings;

sub new {

    my $class = shift;

    return bless {

        _id           => undef,
        _status       => undef,
        _description  => undef,
        _rep_platform => undef,
        _resolution   => undef,
        _user         => undef,
        _activity     => undef,

    }, $class;

}

sub set_id {

    my ( $self, $id ) = @_;
    $self->{_id} = $id;
    return;

}

sub set_status {

    my ( $self, $status ) = @_;
    $self->{_status} = $status;
    return;

}

sub set_description {

    my ( $self, $description ) = @_;
    $self->{_description} = $description;
    return;

}

sub set_rep_platform {

    my ( $self, $rep_platform ) = @_;
    $self->{_rep_platform} = $rep_platform;
    return;

}

sub set_resolution {

    my ( $self, $resolution ) = @_;
    $self->{_resolution} = $resolution;
    return;

}

sub set_user {

    my ( $self, $user ) = @_;
    $self->{_user} = $user;
    return;

}

sub set_activity {

    my ( $self, $activity ) = @_;
    $self->{_activity} = $activity;
    return;

}

sub get_id {

    my $self = shift;
    return $self->{_id};

}

sub get_status {

    my $self = shift;
    return $self->{_status};

}

sub get_description {

    my $self = shift;
    return $self->{_description};

}

sub get_rep_platform {

    my $self = shift;
    return $self->{_rep_platform};

}

sub get_resolution {

    my $self = shift;
    return $self->{_resolution};

}

sub get_user {

    my $self = shift;
    return $self->{_user};

}

sub get_activity {
    
    my $self = shift;
    return $self->{_activity};

}

1;

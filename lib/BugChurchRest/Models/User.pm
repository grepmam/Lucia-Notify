package User;

use strict;
use warnings;

sub new {

    my $class = shift;

    return bless {

        _id       => undef,
        _email    => undef,
        _realname => undef

    }, $class;

}

sub set_id {

    my ( $self, $id ) = @_;
    $self->{_id} = $id;
    return;

}

sub set_email {

    my ( $self, $email ) = @_;
    $self->{_email} = $email;
    return;

}

sub set_realname {

    my ( $self, $realname ) = @_;
    $self->{_realname} = $realname;
    return;

}

sub get_id {

    my $self = shift;
    return $self->{_id};

}

sub get_email {

    my $self = shift;
    return $self->{_email};

}

sub get_realname {

    my $self = shift;
    return $self->{_realname};

}

1;

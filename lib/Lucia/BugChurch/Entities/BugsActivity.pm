package Lucia::BugChurch::Entities::BugsActivity;

use strict;
use warnings;

sub new {

    my $class = shift;

    return bless {

        _added   => undef,
        _removed => undef,

    }, $class;

}

sub set_added {

    my ( $self, $added ) = @_;
    $self->{_added} = $added;
    return;

}

sub set_removed {

    my ( $self, $removed ) = @_;
    $self->{_removed} = $removed;
    return;

}

sub get_added {

    my $self = shift;
    return $self->{_added}; 

}

sub get_removed {

    my $self = shift;
    return $self->{_removed};

}

1;

package Lucia::BugChurch::Proxy;

use strict;
use warnings;

sub new {

    my $class = shift;
    my $self = {
        _model => undef,
    };
    return bless $self, $class;

}

sub use_model {

    my ( $self, $model_name ) = @_;
    
    die "Model does not exist\n" unless $model_name eq 'bug' || $model_name eq 'user';
    
    my $model;

    if ($model_name eq 'bug') {
        $model = $self->_load_model('Lucia::BugChurch::Models::Bug');
    } else {
        $model = $self->_load_model('Lucia::BugChurch::Models::User');
    }

    $self->{_model} = $model;

}

sub get_bugs_by_ids {

    my ( $self, $bugs_string ) = @_;
    
    my $model = $self->{_model};

    die "No model selected. Call use_model() first\n" unless $model;
    die "Operation not allowed for the selected model\n" unless $model->isa('Lucia::BugChurch::Models::Bug');

    return $model->get_bugs_by_ids($bugs_string);

}

sub get_bugs_by_userid {

    my ( $self, $userid ) = @_;
    
    my $model = $self->{_model};

    die "No model selected. Call use_model() first\n" unless $model;
    die "Operation not allowed for the selected model\n" unless $model->isa('Lucia::BugChurch::Models::Bug');

    return $model->get_bugs_by_userid($userid);

}

sub get_user_by_username {

    my ( $self, $username ) = @_;
    
    my $model = $self->{_model};

    die "No model selected. Call use_model() first\n" unless $model;
    die "Operation not allowed for the selected model\n" unless $model->isa('Lucia::BugChurch::Models::User');

    return $model->get_user_by_username($username);

}

sub _load_model {

    my ( $self, $model_class ) = @_;

    eval "require $model_class";
    die "Failed to load $model_class: $@\n" if $@;

    return $model_class->new;

}

1;

package Lucia::Debugger;

use strict;
use warnings;

use constant {
    SUCCESS_SYMBOL => '+',
    WARNING_SYMBOL => '!!',
    FAILURE_SYMBOL => 'x',
    INFO_SYMBOL    => '!',
};


sub success {

    my $message = shift;
    _build_message($message, SUCCESS_SYMBOL);
    return;

}

sub warning {

    my $message = shift;
    _build_message($message, WARNING_SYMBOL);
    return;

}

sub failure {

    my $message = shift;
    _build_message($message, FAILURE_SYMBOL);
    return;

}

sub info {

    my $message = shift;
    _build_message($message, INFO_SYMBOL);
    return;

}

sub _build_message {

    my ( $message, $symbol ) = @_;
    
    my $timestamp = localtime;
    my $log_message = "[$symbol] [$timestamp] $message\n";
    print $log_message;

    return;

}

1;

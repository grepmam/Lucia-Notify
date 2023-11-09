package Lucia::Debugger;

use strict;
use warnings;

use Exporter qw(import);
use Term::ANSIColor qw(colored);

our @EXPORT = qw(
    success
    warning
    failure
    info
);

use constant {
    SUCCESS_COLOR => 'green',
    WARNING_COLOR => 'yellow',
    FAILURE_COLOR => 'red',
    INFO_COLOR    => 'blue'
};


sub success {
    my $message = shift;
    _log_message('SUCCESS', $message, SUCCESS_COLOR);
    return;
}

sub warning {
    my $message = shift;
    _log_message('WARNING', $message, WARNING_COLOR);
    return;
}

sub failure {
    my $message = shift;
    _log_message('FAILURE', $message, FAILURE_COLOR);
    return;
}

sub info {
    my $message = shift;
    _log_message('INFO', $message, INFO_COLOR);
    return;
}

sub _log_message {
    my ($level, $message, $color) = @_;

    my $timestamp = localtime;
    my $log_message = "[$level] [$timestamp] $message\n";
    print colored($log_message, $color);

    return;
}

1;

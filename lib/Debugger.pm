package Debugger;

use strict;
use warnings;


# --------------------------------------------
#
#   GLOBALS
#
# --------------------------------------------


my %type_msgs = (

    success => '+',
    failure => 'x',
    warning => '!',
    info    => '!!',

);


# --------------------------------------------
#
#   Subroutine DISPLAY_MESSAGE
#
# --------------------------------------------
#
#   Show message in console
#
# --------------------------------------------
#
#   -> args: HASH
#       message: text to display 
#       type: type of message. Example: success, 
#           failure, warning, info
#       activate: Check if you want to show the 
#           message
#
#   <- status:
#       completion status. 1 (Success) or 0 (Failure)
#
# --------------------------------------------


sub display_message {

    my %args = @_;
    my ( $message, $type, $activate ) = @args{qw/message type activate/};

    return unless $activate;
    return unless exists $type_msgs{$type};

    print "[$type_msgs{$type}] $message\n";

    return 1;

}


1;

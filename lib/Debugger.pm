#!/usr/bin/perl
#
# Copyright (c) 2023 - Grepmam


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
#   [Description]
# 
#   Displays a message of the specified type with a current date and time
#
# --------------------------------------------
#
#   @param args -> hash:
#     - message -> string: The message to be displayed
#     - type -> string: The type of message (error, warning, information, etc.)
#     - activate -> integer: Flag indicating whether the message should be displayed or not
#
#   @return status -> integer:
#
# --------------------------------------------


sub display_message {

    my %args = @_;
    my ( $message, $type, $activate ) = @args{qw/message type activate/};


    return unless $activate;
    return unless exists $type_msgs{$type};

    my $timestamp = localtime;
    my $log_message = "[$type_msgs{$type}] [$timestamp] $message\n";

    print $log_message;

    return 1;

}


1;

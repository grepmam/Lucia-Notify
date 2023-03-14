#!/usr/bin/perl
#
# Copyright (c) 2023 - Grepmam 
#
# This code is a Perl script tha contains various useful 
# functions for Lucia Notify.


package Utils;

use strict;
use warnings;

use Cwd;
use JSON::MaybeXS;


# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------


use constant {

    SOFTWARE_NAME  => 'Lucia Notify',
    CREATOR        => 'grepmam',
    COLLABORATORS  => 'andrezgz',
    VERSION        => '1.2.0',
    VERSION_STATUS => 'stable',
    VERSION_NAME   => 'Frigg'

};



# --------------------------------------------
#
#   Subroutine DISPLAY_BANNER
#
# --------------------------------------------     
#
#   [Description]
# 
#   Displays a banner in the console with information about the creator and contributors of the app
#
# --------------------------------------------
#
#   [Example]
#
#   display_banner();
#
# --------------------------------------------


sub display_banner {

    my $banner = sprintf '


    ██▓     █    ██  ▄████▄   ██▓ ▄▄▄      
   ▓██▒     ██  ▓██▒▒██▀ ▀█  ▓██▒▒████▄    
   ▒██░    ▓██  ▒██░▒▓█    ▄ ▒██▒▒██  ▀█▄  
   ▒██░    ▓▓█  ░██░▒▓▓▄ ▄██▒░██░░██▄▄▄▄██ 
   ░██████▒▒▒█████▓ ▒ ▓███▀ ░░██░ ▓█   ▓██▒
   ░ ▒░▓  ░░▒▓▒ ▒ ▒ ░ ░▒ ▒  ░░▓   ▒▒   ▓▒█░
   ░ ░ ▒  ░░░▒░ ░ ░   ░  ▒    ▒ ░  ▒   ▒▒ ░
     ░ ░    ░░░ ░ ░ ░         ▒ ░  ░   ▒   
       ░  ░   ░     ░ ░       ░        ░  ░
                    ░                     

            Created by: %s 

          Collaborators: %s

', CREATOR, COLLABORATORS;

    print $banner;

    return 0;

}


# --------------------------------------------
#
#   Subroutine DISPLAY_OPTIONS
#
# --------------------------------------------     
#
#   [Description]
# 
#   Displays the application usage options in the console
#
# --------------------------------------------
#
#   [Example]
#
#   display_options(); 
#
# --------------------------------------------


sub display_options {

    my $options = qq|
USAGE: ./lucia-notify [OPTIONS]

Lucia Notify is a tool that will notify you in case a Bugzilla
bug changes its status. In the event that your tester friend or 
person in charge changes the status in Bugzilla, you will not 
have to wait to enter the page and review, Sister Lucía will do 
it for you.


ARGUMENTS:

  --bugs BUG_LIST                   A list of bugs separated by ','
  -u NLASTNAME, --user NLASTNAME    Username consisting of N(Name) and LASTNAME.
  -b BUG_ID, --bugid BUG_ID         Bug ID
  --time TIME                       Time per query to the database. Default: 30
  -t, --testing                     Try the Lucia Notifier
  -s, --sound                       Activate sound notification
  -v, --voice                       Activate Lucia's voice
  -l, --lang                        Change Lucia's language. Languages: es (spanish) and en (english). Default: us.
  -d, --debug                       Activate debugging mode
  --no-greeting                     Don't display Lucia greeting
  --no-banner                       Don't display banner
  --version                         Display version
  -h, --help                        Display this


EXAMPLES:

  ./lucia-notify --bugs '12332,31542'
  ./lucia-notify --bugs --user lbellucci
  ./lucia-notify -b 32122

    \n|;

    print $options;

    return 0;

}


# --------------------------------------------
#
#   Subroutine DISPLAY_VERSION
#
# --------------------------------------------     
#
#   [Description]
# 
#   Displays the version of the application in the console
#
# --------------------------------------------
#
#   [Example]
#
#   display_version(); 
#
# --------------------------------------------


sub display_version {

    print sprintf "%s version %s-%s %s\n", SOFTWARE_NAME, VERSION, VERSION_STATUS, VERSION_NAME;

    return 0;

}


# --------------------------------------------
#
#   Subroutine GET_ABS_PATH
#
# --------------------------------------------     
#
#   [Description]
# 
#   Returns an absolute path from a relative path inside from Lucia-Notify directory
#
# --------------------------------------------
#
#   @param relative_file_path -> string: relative path
#
#   @return absolute_path -> string: return absolute path
#
# --------------------------------------------
#
#   [Example]
#
#   get_abs_path('icons/'); 
#
# --------------------------------------------


sub get_abs_path {

    my $relative_file_path = shift;

    return Cwd::abs_path('.') . '/' . $relative_file_path;

}


sub load_json {

    my $relative_file_path = shift;
    my $file_path = get_abs_path $relative_file_path;

    my $json = JSON->new;

    open my $fh, '<', $file_path or die "No se puede abrir el archivo: $!";
    my $json_text = do { local $/; <$fh> }; 
    close $fh;

    my $data = decode_json $json_text;

    return $data;

}


1;

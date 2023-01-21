package Utils;

use strict;
use warnings;


# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------


use constant {

    SOFTWARE_NAME  => 'Lucia Notify',
    CREATOR        => 'grepmam',
    COLLABORATORS  => 'andrezgz',
    VERSION        => '1.0.0',
    VERSION_STATUS => 'stable',
    VERSION_NAME   => 'Frigg'

};



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
  -d, --debug                       Activate debugging mode
  --no-greeting                     Don't display Lucia greeting
  --no-banner                       Don't display banner
  -v, --version                     Display version
  -h, --help                        Display this


EXAMPLES:

  ./lucia-notify --bugs '12332,31542'
  ./lucia-notify --bugs --user lbellucci
  ./lucia-notify -b 32122

    \n|;

    print $options;

    return 0;

}


sub display_version {

    print sprintf( '%s version %s-%s %s', SOFTWARE_NAME, VERSION, VERSION_STATUS, VERSION_NAME ) . "\n";

    return 0;

}


1;

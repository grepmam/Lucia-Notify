package Utils;

use strict;
use warnings;


# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------


my $SOFTWARE_NAME  = 'Lucia Notify';
my $CREATOR        = 'grepmam';
my $COLLABORATORS  = 'andrezgz';
my $VERSION        = '1.0.0';
my $VERSION_STATUS = 'unstable';
my $VERSION_NAME   = 'Frigg';



# --------------------------------------------


sub display_banner {

    my $banner = qq|  


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

            Created by: $CREATOR 

          Collaborators: $COLLABORATORS

|;

    print $banner;

    return 1;

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

    print "$SOFTWARE_NAME version $VERSION-$VERSION_STATUS $VERSION_NAME\n\n";

    return 1;

}


1;

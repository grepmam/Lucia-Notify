package Lucia::Utils::UI;

use strict;
use warnings;


use constant {
    SOFTWARE_NAME  => 'Lucia Notify',
    CREATOR        => 'grepmam',
    VERSION        => '2.0.0',
    VERSION_STATUS => 'unstable',
    VERSION_NAME   => 'Saga'
};


sub _get_collaborators {
    my @collaborators_list = ('andrezgz', 'aholtz');
    return join ', ', @collaborators_list;
}

sub show_banner {
    my $collaborators = _get_collaborators();

    my $banner = sprintf('
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

       Collaborators %s

         Version: %s (%s)

', CREATOR, $collaborators, VERSION, VERSION_STATUS);

    print $banner;

    return;
}

sub show_version {
    my $version = sprintf "%s version %s-%s %s\n",
        SOFTWARE_NAME,
        VERSION,
        VERSION_STATUS,
        VERSION_NAME;

    print $version;

    return;
}

sub show_help {
    my $help = qq|
Usage: lucia COMMAND {ARGUMENT} [OPTIONS]

Lucia Notify is a tool that will notify you in case a Bugzilla
bug changes its status. In the event that your tester friend or 
person in charge changes the status in Bugzilla, you will not 
have to wait to enter the page and review, Sister Lucía will do 
it for you.


Available commands:

  user                   Notify user by username
  bugs                   Notify user by set of bug IDs
  simulate               Create a fake notification in a 10 second interval


Command flags:

  -s, --sound            Activate sound notification
  -v, --voice            Activate Lucia's voice
  -l, --lang LANG        Change Lucia's language. Languages: es (spanish) and en (english). Default: us.
  -d, --debug            Activate debugging mode
  -t, --time TIME        Time per query to the database. Default: 30
      --no-greeting      Don't display Lucia greeting


Global flags:

  -h, --help             Display this
      --no-banner        Don't display banner
      --version          Display version


EXAMPLES:

  lucia user lbellucci --sound --voice
  lucia bugs 4123 --lang es
  lucia simulate 6553,2313 --debug
  lucia user lbellucci --no-greeting -t 40
    \n|;

    print $help;

    return;
}

1;

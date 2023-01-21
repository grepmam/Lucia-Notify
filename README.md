<p align="center">
  <img width="200" src="https://i.imgur.com/nhNN7bE.png">
</p>

<div align="center">

  <a href="https://github.com/grepmam">![grepmam](https://img.shields.io/badge/Created%20by-Grepmam-red)</a>
  <a href="https://www.perl.org/">![perl](https://img.shields.io/badge/Written%20in-Perl-green)</a>
  <a>![version](https://img.shields.io/badge/Version-Frigg-yellow)</a>

</div>

Lucia Notify is a tool that will notify you in case a Bugzilla bug changes its status. In the event that your tester friend or person in charge changes the status in Bugzilla, you will not have to wait to enter the page and review, Sister Lucía will do it for you.

## Install

To install, just run:

```bash 
./install
```

## Configure

There is an .env file in the main directory that you will need to use to configure the database:

```
DATABASE_NAME=
DATABASE_HOST=
DATABASE_PORT=
DATABASE_USER=
DATABASE_PASS=
```

## Usage

### Notify for one bug

To report a bug by id:

```bash
lucia --bugid 32122
```

### Notify for user bugs

To report all bugs for a user:

```bash
lucia --user lbellucci
```

### Notify for bugs

To report specific bugs:

```bash
lucia --bugs '12332,31542'
```

## Other features

### Testing

You can test how the notification looks or if it is ok:

```bash
lucia --bugid 51111 --testing
```

### Sound

If you want the notification to be heard, the --sound flag can be used:

```bash
lucia --bugid 17111 --sound
```

### Debug mode

In case something is wrong, you can use this mode:

```bash
lucia --bugid 17111 --debug
```

### False timer

Due to the expensive work of querying the database every millisecond, there is a flag to set the time between queries. By default it is 30 seconds, but if you want a custom time:

```bash
lucia --bugid 19011 --time 20
```

## Daemon mode


***User**: All very nice, but I don't like having to start the script every time I turn on the computer. Is there any way to avoid that?*

Yes, with this mode you can forget about such problems. I'll show you how.*


We will copy the .services into the **~/.config/systemd/user/** folder. Create it if it doesn't exist:

```bash
cp --force systemd/*.service $HOME/.config/systemd/user/
```
Modify the user in the templates. They will find it as "**\<user\>**":

```bash
systemctl --user edit --full x_start
systemctl --user edit --full lucia
```

We let Systemd know that the services are there:

```bash
systemctl --user daemon-reload
```
We enable them to run after boot:

```bash
systemctl --user enable x_start
systemctl --user enable lucia
```

We start the services;

```bash
systemctl --user start x_start
systemctl --user start lucia
```

***Note***: an automatic version of the process is being prepared.

Then you have to configure the variables of the .env file to your liking, only those with the LUCIA prefix:

```
LUCIA_USERNAME=
LUCIA_TIME=20
LUCIA_SOUND=true
LUCIA_NOBANNER=true
LUCIA_NOGREETING=true
```

As a recommendation, just change the username.

## Examples

```bash
lucia -u lbellucci -s -d 
lucia --bugs '18111,10999' --sound --time 15 --debug
```


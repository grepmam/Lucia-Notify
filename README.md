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

## Examples

```bash
lucia -u lbellucci -s -d 
lucia --bugs '18111,10999' --sound --time 15 --debug
```

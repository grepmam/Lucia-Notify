package Lucia::ProtoTTS;

use strict;
use warnings;

use JSON qw(decode_json);
use Encode qw(encode);
use File::Which;
#use File::Temp;

use LWP::UserAgent;
#use Audio::Play::MPG123;


# --------------------------------------------
#
#   CONSTANTS
#
# --------------------------------------------

use constant {
    
    TTS_SERVICE    => 'ttsmp3',
    DEFAULT_VOICE  => 'Kimberly',
    MAX_CHARACTERS => 3000

};


# --------------------------------------------
#
#   GLOBALS
#
# --------------------------------------------

our $ua = LWP::UserAgent->new;
our $service_url = sprintf 'https://%s.com', TTS_SERVICE;


sub new {

    my $class = shift;

    return bless {

        _message => '',
        _voice   => DEFAULT_VOICE,
        _source  => TTS_SERVICE

    }, $class;

}


sub set_message {

    my ( $self, $message ) = @_;

    $self->{_message} = length $message > MAX_CHARACTERS
        ? substr $message, 0, MAX_CHARACTERS
        : $message;
    $self->{_message} = encode 'utf-8', $self->{_message};

    return;

}


sub set_voice {

    my ( $self, $voice ) = @_;
    $self->{_voice} = $voice;
    return;

}


sub play {

    my $self = shift;

    my $audio_url = $self->_get_audio_url;
    die "Failed to get audio URL\n" unless $audio_url;

    my $audio_content = $self->_get_page_content( $audio_url );
    die "Could not get the content of the URL\n" unless $audio_content;
    
    my $audio_filename = sprintf '/tmp/%s', $self->_get_audio_name( $audio_url );
    $self->_create_tempfile( $audio_filename, $audio_content );

    $self->_speak( $audio_filename );

    unlink $audio_filename;

    # Deprecated due to unknown issues 
    #my $player = Audio::Play::MPG123->new;
    #$player->load( $audio_filename );
    #$player->poll(1) until $player->state == 0;

    return;

}


sub _get_audio_url {

    my $self = shift;
    my $message = $self->{_message};
    my $voice = $self->{_voice};
    my $source = $self->{_source};

    my $url = "$service_url/makemp3_new.php";
    my $data = "msg=$message&lang=$voice&source=$source";

    my $response = $ua->post( $url, Content => $data );
    my $ttsmp3_json = $response->is_success
        ? decode_json $response->decoded_content
        : {}; 

    return '' unless $ttsmp3_json;
    return $ttsmp3_json->{URL};

}


sub _get_page_content {

    my ( $self, $url ) = @_;

    my $response = $ua->get( $url );
    return '' unless $response->is_success;
    return $response->decoded_content;

}


sub _get_audio_name {

    my ( $self, $url ) = @_;
    my @url_parts = split /\//, $url;
    return $url_parts[-1];

}


sub _create_tempfile {

    my ( $self, $filename, $content ) = @_;

    open( my $fh, '>', $filename ) or die "Could not create file\n";
    print $fh $content;
    close $fh;

    # Deprecated due to unknown issues
    #my $tempfile = File::Temp->new( SUFFIX => '.mp3' );
    #print $tempfile $audio_content;
    #close $tempfile;

    return;

}


sub _speak {

    my ( $self, $audio_filename ) = @_;

    my $mpv_path = which 'mpv';
    system "$mpv_path --no-video $audio_filename &>/dev/null";

    return;

}


sub _Get_Speakers {

    my $class = shift;

    my $response = $ua->get( $service_url );

    return {} unless $response->is_success;
    
    my $content = $response->decoded_content;
    my $speakers = {};

    while ( $content =~ /<option[^>]*>(.+?)<\/option>/ig ){
        my $item = encode 'utf-8', $1;
        my ( $lang, $voice ) = split /\s\/\s/, $item;
        $speakers->{$lang} = [] unless exists $speakers->{$lang};
        push @{$speakers->{$lang}}, $voice;
    }

    return $speakers;

}


sub List_Langs {

    my $class = shift;

    my $speakers = $class->_Get_Speakers;
    die "There are no speakers\n" unless $speakers;

    my @langs = keys %$speakers;
    foreach my $lang (@langs){ print "$lang\n"; }

    return;

}


sub List_Voices {

    my ( $class, $lang ) = @_;

    my $speakers = $class->_Get_Speakers;
    die "There are no speakers\n" unless $speakers;
    die "Language does not exist\n" unless exists $speakers->{$lang};

    my $voices = $speakers->{$lang}; 
    foreach my $voice (@$voices){ print "$voice\n"; }

    return;

}


1;

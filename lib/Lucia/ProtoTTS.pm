package Lucia::ProtoTTS;

use strict;
use warnings;

use JSON qw(decode_json);
use Encode qw(encode);
use File::Which;

use LWP::UserAgent;


use constant {
    
    TTS_SERVICE    => 'ttsmp3',
    DEFAULT_VOICE  => 'Kimberly',
    MAX_CHARACTERS => 3000

};

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

    my $status = $self->_speak( $audio_filename );

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

    return;

}


sub _speak {

    my ( $self, $audio_filename ) = @_;

    my $mpv_path = which 'mpv';
    system "( $mpv_path --no-video $audio_filename && rm $audio_filename ) > /dev/null 2>&1";

    return;

}


1;

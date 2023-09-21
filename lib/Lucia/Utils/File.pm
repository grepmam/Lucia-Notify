package Lucia::Utils::File;

use strict;
use warnings;

use JSON::MaybeXS qw(decode_json);


sub load_json {

    my $file_path = shift;
    my $json = JSON->new;
    open my $fh, '<', $file_path or die "[x] Can't open the file: $!\n";
    my $json_text = do { local $/; <$fh> }; 
    close $fh;

    my $data = decode_json $json_text;

    return $data;

}


1;

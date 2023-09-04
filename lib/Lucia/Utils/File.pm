package Lucia::Utils::File;

use strict;
use warnings;

use Cwd;
use JSON::MaybeXS;


sub absolute_path {

    my $relative_path = shift;
    return Cwd::abs_path('.') . '/../' . $relative_path;

}


sub load_json {

    my $relative_path = shift;
    my $file_path = absolute_path $relative_path;
    my $json = JSON->new;
    open my $fh, '<', $file_path or die "[x] Can't open the file: $!\n";
    my $json_text = do { local $/; <$fh> }; 
    close $fh;

    my $data = decode_json $json_text;

    return $data;

}


1;

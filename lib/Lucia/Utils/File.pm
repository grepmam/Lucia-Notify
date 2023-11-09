package Lucia::Utils::File;

use strict;
use warnings;

use FindBin qw($RealBin);
use JSON::MaybeXS qw(decode_json);
use Exporter qw(import);

our @EXPORT_OK = qw(get_resources_dir load_json);


sub load_json {
    my $file_path = shift;

    my $json = JSON->new;
    open my $fh, '<', $file_path or die "[x] Can't open the file: $!\n";
    my $json_text = do { local $/; <$fh> }; 
    close $fh;

    my $data = decode_json $json_text;

    return $data;
}

sub get_resources_dir {
    return "$RealBin/../resources";
}

1;

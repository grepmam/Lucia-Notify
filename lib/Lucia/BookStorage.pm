package Lucia::BookStorage;

use strict;
use warnings;

use FindBin qw($RealBin);
use Storable qw(store retrieve);

use constant BOOK_STORAGE_DIR  => "$RealBin/../storage";
use constant BOOK_STORAGE_FILE => 'book.dat';
use constant BOOK_STORAGE_FILEPATH => sprintf '%s/%s', BOOK_STORAGE_DIR, BOOK_STORAGE_FILE;


sub new {

    my $class = shift;
    
    my $self = {
        _book => undef
    };

    bless $self, $class;
 
    $self->_create_book_storage;

    return $self;

}

sub _create_book_storage {

    my $self = shift;

    $self->_create_storage_directory;
    store {recently_created => 1}, BOOK_STORAGE_FILEPATH unless -e BOOK_STORAGE_FILEPATH;
    $self->{_book} = retrieve BOOK_STORAGE_FILEPATH;

    return;

}

sub _create_storage_directory {

    my $self = shift;
    mkdir(BOOK_STORAGE_DIR, 0700) unless -d BOOK_STORAGE_DIR;
    return;

}

sub is_new {

    my $self = shift;
    return $self->{_book}->{recently_created};

}

sub enable_used_book {

    my $self = shift;
    $self->{_book}->{recently_created} = 0;

}

sub get_bug_ids {

    my $self = shift;
    return keys %{$self->{_book}->{bugs}};

}

sub get_bug_by_id {

    my ($self, $id) = @_;
    return $self->{_book}->{bugs}->{$id};

}

sub delete_bug_by_id {

    my ($self, $id) = @_;
    delete $self->{_book}->{bugs}->{$id};
    return;

}

sub update_book {

    my $self = shift;

    store $self->{_book}, BOOK_STORAGE_FILEPATH;
    $self->{_book} = retrieve BOOK_STORAGE_FILEPATH;

    return;

}

sub save_bug {

    my ($self, $bug) = @_;

    $self->{_book}->{bugs}->{$bug->get_id} = $bug;
    $self->update_book;

    return;

}

sub bug_exists {

    my ($self, $id) = @_;
    return exists $self->{_book}->{bugs}->{$id};

}

1;

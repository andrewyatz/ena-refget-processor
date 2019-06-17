#!/usr/bin/env perl

use strict;
use warnings;
use Path::Tiny qw(path);
use Getopt::Long;
use Pod::Usage;

use lib path($0)->absolute->parent(2)->child('lib')->stringify;
use ProcessEmbl;
use Log::Writer;
use Log::Full;
use Log::VersionLookup;
use Log::Loader;

my $options = {
  man => 0,
  help => 0,
  type => 'expanded_con'
};
GetOptions($options, qw/
  store-path=s
  file-path=s
  process-id=s
  help|?
  man
/) or pod2usage(2);

pod2usage(1) if $options->{help};
pod2usage(-exitval => 0, -verbose => 2) if $options->{man};

my $store_path = path($options->{'store-path'});
my $file_path = path($options->{'file-path'});
my $process_id = $options->{'process-id'};

sub run {
  my $log_store_path  = $store_path->child('logs');
  my $full_log        = Log::Writer->new(target => $log_store_path->child("${process_id}.full.csv"));
  my $loader_log      = Log::Writer->new(target => $log_store_path->child("${process_id}.loader.csv"));
  my $version_log     = Log::Writer->new(target => $log_store_path->child("${process_id}.version.csv"));

  my $process_embl = ProcessEmbl->new(
    path => $file_path,
    sequence_store_path => $store_path->child('seq'),
    metadata_store_path => $store_path->child('json'),
    handler => sub {
      my ($metadata) = @_;
      $full_log->write(Log::Full->new(metadata => $metadata, ena_type => $options->{type}));
      $version_log->write(Log::VersionLookup->new(metadata => $metadata));
      $loader_log->write(Log::Loader->new(metadata => $metadata, completed => 1));
      return;
    }
  );
  $process_embl->process();
}

run();

 __END__
=head1 NAME

load_expanded_con.pl - Load an INSDC expanded con file. Most likely from INSDC

=head1 SYNOPSIS

load_expanded_con.pl [options]

  Options:
    --help            brief help message
    --man             full documentation
    --store-path      base directory where sequences, json and logs will go
    --file-path       location of the input file
    --process-id      identifier for this process (used to create log files)

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION

B<load_expanded_con.pl> will read the given input file(s) and process them into refget compatible files.

=cut
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

use strict;
use warnings;
use Test::More;
use Test::Differences;
use Test::Exception;

use Path::Tiny qw/path tempdir/;
use IO::Scalar;
use DateTime::Tiny;

use ProcessEmbl;
use Log::Full;
use Log::Loader;
use Log::Writer;
use Log::VersionLookup;

my $accession = 'ML136216';
my $version = '1';
my $versioned_accession = "${accession}.${version}";
my $species = 'Bemisia tabaci';
my $biosample = 'SAMN03382551';
my $taxon = 7038;

my $data_path = path(__FILE__)->absolute()->parent()->child('data');
my $uncompressed_embl = $data_path->child("${versioned_accession}.dat.gz");
my $gz_embl = $data_path->child("${versioned_accession}.dat.gz");

my $trunc512 = 'da8d7fe34fcc0dc383a81fa5a315bdff22eb4874e60d12fe';
my $md5 = '648d2b9022e3189736541c85efa9ec06';
my $length = 30627;
my $sha512 = 'da8d7fe34fcc0dc383a81fa5a315bdff22eb4874e60d12fefe3256f9fae8fef537f05c1398b0b87a28d9831789848f6bd772bfaf800e2e9400d330e6fc90c1ac';
my $trunc512_base64 = '2o1_40_MDcODqB-loxW9_yLrSHTmDRL-';
my $ena_type = 'expanded_con';
my $expected_metadata = {
  metadata => {
    aliases => [
      { alias => $versioned_accession, naming_authority => 'INSDC' },
      { alias => $sha512, naming_authority => 'sha512' },
      { alias => $trunc512_base64, naming_authority => 'trunc512_base64' },
    ],
    length => 30627,
    md5 => $md5,
    trunc512 => $trunc512,
    id => $trunc512,
  }
};

my $run_test = sub {
  my ($embl_path, $type) = @_;
  note "Processing file type $type from path $embl_path";

  my $sequence_store_path = tempdir();
  my $metadata_store_path = tempdir();
  my $expected_seq_target = $sequence_store_path->child('da')->child('8d')->child('7f')->child($trunc512);
  my $expected_metadata_target = $metadata_store_path->child('da')->child('8d')->child('7f')->child($trunc512.'.json');
  my $completed = 1;

  my $process_embl = ProcessEmbl->new(path => $embl_path, sequence_store_path => $sequence_store_path, metadata_store_path => $metadata_store_path, handler => sub {
    my ($metadata) = @_;

    # Check written sequence & metadata are as as expected
    my $seq_path = $metadata->seq_path()->absolute()->stringify();
    my $json_path = $metadata->json_path()->absolute()->stringify();
    eq_or_diff($metadata->to_refget_metadata_hash(), $expected_metadata, "Checking metadata ${type}");
    note "Written sequence path for $type is $seq_path";
    is($seq_path, $expected_seq_target->absolute->stringify(), "Sequence writing path as expected for ${type}");
    note "Written metadata path for $type is $json_path";
    is($json_path, $expected_metadata_target->absolute->stringify(), "Metadata writing path as expected for ${type}");

    # Check the logging system works
    my $timestamp = DateTime::Tiny->now();
    my $expected_full_log = [$trunc512, $md5, $length, $sha512, $trunc512_base64, $versioned_accession, $ena_type, $species, $biosample, $taxon];
    my $full_log = Log::Full->new(metadata => $metadata, ena_type => $ena_type, timestamp => $timestamp);
    eq_or_diff($full_log->columns(), $expected_full_log, "Generated full log event as expected for ${type}");

    my $expected_loader_log = [$timestamp->as_string(), $completed, $trunc512, $md5, $seq_path, $json_path];
    my $loader_log = Log::Loader->new(metadata => $metadata, timestamp => $timestamp, completed => $completed);
    eq_or_diff($loader_log->columns(), $expected_loader_log, "Generated loader log event as expected for ${type}");

    # Test log output
    my $log_output = '';
    my $expected_log_output = qq{timestamp,completed,trunc512,md5,seq_path,json_path
$timestamp,$completed,$trunc512,$md5,$seq_path,$json_path
};
    my $fh = IO::Scalar->new(\$log_output);
    my $writer = Log::Writer->new(fh => $fh);
    $writer->write($loader_log);
    is($log_output, $expected_log_output, "Checking log is generated as expected for ${type}");

    # Test mixed log output behaves as expected i.e. fails
    throws_ok { $writer->write($full_log) } qr/count/, 'Checking that we cannot write to a CSV file where the columns differ in numbers';

    # Testing output from VersionLookup log (should be null because it's a v1 record)
    ok(! defined Log::VersionLookup->new(metadata => $metadata)->columns(), 'Checking a v1 record does not generate a VersionLog instance');
    return;
  });
  $process_embl->process();
};

$run_test->($uncompressed_embl, 'uncompressed embl');
$run_test->($gz_embl, 'gzip embl');

done_testing();

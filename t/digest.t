use strict;
use warnings;

use Test::More;
use Metadata;
use Bio::Seq;
use Bio::Species;

my $classification = [qw(
  sapiens Homo Hominidae
  Catarrhini Primates Eutheria
  Mammalia Vertebrata Chordata
  Metazoa Eukaryota
)];
my $checksum = 'aKF498dAxcJAqme6QYQ7EZ07-fiw8Kw2';
my $seq = 'ACGT';

my $bioseq = Bio::Seq->new(
  -seq => $seq,
  -id => 'id',
  -version => 1,
  -accession_number => 'accession',
  -species => Bio::Species->new(-classification => $classification)
);

my $m = Metadata->create_from_seq($bioseq, 9606);
is($m->ga4gh(), 'ga4gh:SQ.'.$checksum, 'Checking GA4GH checksum default works');

done_testing();
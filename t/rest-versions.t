use strict;
use warnings;

use Test::More;
use RestEmbl;
use Test::Fake::HTTPD;

delete $ENV{HTTP_PROXY} if $ENV{HTTP_PROXY};
delete $ENV{http_proxy} if $ENV{http_proxy};

# Create and edit later once we know what the endpoint URL is
my $json = <<'EOL';
{"accession":"CM000663","versions":[{"accession":"CM000663","sequenceVersion":2,"firstPublic":"09-MAR-2009","lastUpdated":"15-MAY-2014","text":"https://www.ebi.ac.uk/ena/browser/api/text/CM000663.2","fasta":"https://www.ebi.ac.uk/ena/browser/api/fasta/CM000663.2","status":"public"},{"accession":"CM000663","sequenceVersion":1,"firstPublic":"09-MAR-2009","lastUpdated":"29-SEP-2009","text":"https://www.ebi.ac.uk/ena/browser/api/text/CM000663.1","status":"suppressed"}]}
EOL

my $fasta = <<'EOL';
>ENA|CM000663|CM000663.2 Homo sapiens chromosome 1, GRCh38 reference primary assembly.
NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
EOL

my $embl = qq{ID   CM000663; SV 1; linear; genomic DNA; CON; HUM; 249250621 BP.
XX
AC   CM000663;
XX
PR   Project:PRJNA31257;
XX
DT   09-MAR-2009 (Rel. 100, Created)
DT   29-SEP-2009 (Rel. 102, Last updated, Version 2)
XX
DE   Homo sapiens chromosome 1, GRCh37 primary reference assembly.
XX
KW   .
XX
OS   Homo sapiens (human)
OC   Eukaryota; Metazoa; Chordata; Craniata; Vertebrata; Euteleostomi; Mammalia;
OC   Eutheria; Euarchontoglires; Primates; Haplorrhini; Catarrhini; Hominidae;
OC   Homo.
XX
XX
XX
FH   Key             Location/Qualifiers
FH
FT   source          1..249250621
FT                   /organism="Homo sapiens"
FT                   /chromosome="1"
FT                   /mol_type="genomic DNA"
FT                   /db_xref="taxon:9606"
XX
CO   join(gap(10000),GL000001.1:1..257719,gap(50000),GL000002.1:1..153649,
CO   gap(50000),GL000003.1:1..3323900,gap(150000),GL000004.1:1..9224644,
CO   gap(100000),GL000005.1:1..16558170,gap(150000),GL000006.1:1..90908613,
CO   gap(150000),GL000007.1:1..398739,gap(50000),gap(3000000),gap(18000000),
CO   GL000008.1:1..432327,gap(150000),GL000009.1:1..426764,gap(100000),
CO   GL000010.1:1..126477,gap(100000),GL000011.1:1..224781,gap(50000),
CO   GL000012.1:1..78698,gap(50000),GL000013.1:1..347932,gap(50000),
CO   GL000014.1:1..3353625,gap(150000),GL000015.1:1..185320,gap(150000),
CO   GL000016.1:1..57411349,gap(150000),GL000017.1:1..259514,gap(150000),
CO   GL000018.1:1..42425989,gap(150000),GL000019.1:1..182411,gap(10000))
//
};

my $httpd = get_server();
my $endpoint = $httpd->endpoint;

my $rest_embl = RestEmbl->new(server => "$endpoint");
my $versions = $rest_embl->get_versions('CM000663');
is(2, $versions->[0]->sequenceVersion(), 'Checking 1st element is version 2');
is(1, $versions->[1]->sequenceVersion(), 'Checking 2nd element is version 1');
ok(!$versions->[1]->has_fasta(), 'Checking 2nd element has no FASTA URL');

is($fasta, $rest_embl->get_fasta($versions->[0]), 'First element can retreive FASTA');
is($embl, $rest_embl->get_embl($versions->[1]), 'First element can retreive EMBL record');

done_testing();

sub get_server {
  my ($self) = @_;
  my $httpd = Test::Fake::HTTPD->new(
    timeout => 30,
  );

  $httpd->run(sub {
    my ($req) = @_;
    my $uri = $req->uri;
    return do {
      if( $uri->path eq '/ena/browser/api/versions/CM000663' ) {
        # Muck around with the JSON string so subsequent calls come back to this server
        my $json_copy = $json;
        my $host = 'http://'.$req->headers->header('host');
        $json_copy =~ s/https\:\/\/www.ebi.ac.uk/$host/g;
        [ 200, [ 'Content-Type', 'application/json' ], [ $json_copy ] ];
      }
      elsif( $uri->path eq '/ena/browser/api/fasta/CM000663.2' ) {
        [ 200, [ 'Content-Type', 'text/plain' ], [ $fasta ] ];
      }
      elsif( $uri->path eq '/ena/browser/api/text/CM000663.1' ) {
        [ 200, [ 'Content-Type', 'text/plain' ], [ $embl ] ];
      }
      else {
        [404, [ 'Content-Type', 'text/plain' ], ['Unsupported URL']];
      }
    }
  });
  ok( defined $httpd, 'Got a web server' );
  diag( sprintf "You can connect to your server at %s.\n", $httpd->host_port );
  return $httpd;
}

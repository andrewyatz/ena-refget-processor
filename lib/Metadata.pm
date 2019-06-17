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

package Metadata;

use Moose;
use MIME::Base64 qw/encode_base64url/;
use Checksum::MD5;
use Checksum::SHA512;

has 'md5'           =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'sha512'        =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'length'        =>  ( isa => 'Int', is => 'ro', required => 1 );
has 'accession'     =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'species'       =>  ( isa => 'Str', is => 'ro', required => 1 );
has 'biosample'     =>  ( isa => 'Str', is => 'ro', required => 0 );
has 'taxon'         =>  ( isa => 'Int', is => 'ro', required => 0 );
has 'version'       =>  ( isa => 'Int', is => 'ro', required => 1 );

has 'json_path'     =>  ( isa => 'Path::Tiny', is => 'rw', predicate => 'has_json_path' );
has 'seq_path'      =>  ( isa => 'Path::Tiny', is => 'rw', predicate => 'has_seq_path' );

sub create_from_seq {
  my ($self, $seq) = @_;
  my $md5 = Checksum::MD5->new()->process($seq);
  my $sha512 = Checksum::SHA512->new()->process($seq);
  my $length = $seq->length();
  my $id = $seq->id();
  my $version = $seq->version();
  my $species = $seq->species()->scientific_name();
  my ($biosample) = grep { $_->database() eq 'BioSample' } $seq->get_Annotations('dblink');
  my ($taxon) = map { $_ =~ /^taxon:(\d+)$/; $1; }
                grep { $_ =~ /^taxon:\d+$/ }
                map { $_->get_tag_values('db_xref') }
                $seq->get_SeqFeatures('source');

  return Metadata->new(
    sha512 => $sha512,
    md5 => $md5,
    length => $length,
    accession => $id,
    version => $version,
    species => $species,
    biosample => $biosample->primary_id(),
    taxon => $taxon,
  );
}

sub versioned_accession {
  my ($self) = @_;
  return $self->accession().q{.}.$self->version();
}

sub trunc512 {
  my ($self) = @_;
  my $sha512 = $self->sha512();
  my $trunc512 = substr($sha512, 0, 48);
  return $trunc512;
}

sub trunc512_base64 {
	my ($self) = @_;
  my $trunc_digest = $self->trunc512();
	my $bytes = pack("H*", $trunc_digest);
	my $base64 = encode_base64url($bytes);
	return $base64;
}

sub to_refget_metadata_hash {
  my ($self) = @_;
  return {
    metadata => {
      length => $self->length,
      md5 => $self->md5,
      trunc512 => $self->trunc512,
      id => $self->trunc512,
      aliases => [
        { alias => $self->versioned_accession, naming_authority => 'INSDC' },
        { alias => $self->sha512, naming_authority => 'sha512' },
        { alias => $self->trunc512_base64, naming_authority => 'trunc512_base64' },
      ]
    }
  };
}

__PACKAGE__->meta->make_immutable;

1;

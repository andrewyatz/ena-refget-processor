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

package ProcessMetadata;

use Moose;
use Metadata;
use JSON qw/encode_json/;
use Digest::MD5 qw/md5_hex/;

with 'BaseProcess';

has 'seq' =>  ( isa => 'Bio::PrimarySeqI', is => 'ro', required => 1 );

sub process {
  my ($self) = @_;
  my $seq = $self->seq();
  my $metadata = Metadata->create_from_seq($seq);
  my $target_dir = $self->get_target_dir($metadata);
  my $target = $target_dir->child($metadata->trunc512().'.json');
  my $json = encode_json($metadata->to_refget_metadata_hash());
  $target->spew($json);
  my $md5 = md5_hex($json);
  $self->check_content($target, $md5);
  $metadata->path($target);
  return $metadata;
}

__PACKAGE__->meta->make_immutable;

1;
